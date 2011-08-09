/*jslint devel: true, browser: true, sloppy: true, vars: true, white: true, maxerr: 50, indent: 4 */

var Formize = {};

Formize.Overlay = {
    
    count : 0,

    add : function (body) {
        body = body || document.body || document.getElementsByTagName("BODY")[0];
        var dims   = document.viewport.getDimensions();
        var height = dims.height, width = dims.width, overlay = $('overlay');
        if (overlay === null) {
            overlay = new Element('div', {id: 'overlay', style: 'position:fixed; top:0; left 0; width:'+width+'px; height: '+height+'px; opacity: 0.5'});
            body.appendChild(overlay);
	}
        this.count += 1;
	overlay.setStyle({'z-index': this.z_index});
        return overlay;
    },
    
    remove: function() {
        this.count -= 1;
        var overlay = $('overlay');
	if (overlay !== null) {
            if (this.count <= 0) {
		overlay.remove();
	    } else {
		overlay.setStyle({'z-index': this.z_index});
	    }
        }
        return this.count;
    },
    
    // Computes a big z-index with interval in order to intercalate dialogs
    z_index: function() {
	return (10*this.count + 10000);
    }
};


Formize.Dialog = {

    /* Opens a div like a virtual popup*/
    open: function (url, updated, ratio) {
        var body   = document.body || document.getElementsByTagName("BODY")[0];
        var dims   = document.viewport.getDimensions();
        var height = dims.height; 
        var width  = dims.width;
        var dialog_id = 'dialog'+Formize.Overlay.count;
        if (isNaN(ratio)) { ratio = 0.6; }
        
        Formize.Overlay.add();
        
        return new Ajax.Request(url, {
            method: 'get',
            parameters: {dialog: dialog_id},
            evalScripts: true,
            onSuccess: function(response) {
                var dialog = new Element('div', {id: dialog_id, 'data-ratio': ratio, 'data-dialog-update': updated, flex: '1', 'class': 'dialog', style: 'z-index:'+(Formize.Overlay.z_index+1)+'; position:fixed; opacity: 1'});
                body.appendChild(dialog);
                dialog.update(response.responseText);
                var w = ratio*width;
                var h = ratio*height;
                if (ratio <= 0) {
                    var dialogDims = dialog.getDimensions();
                    w = dialogDims.width;
                    h = dialogDims.height;
                }
                dialog.setStyle('left:'+((width-w)/2)+'px; top:'+((height-h)/2)+'px; width:'+w+'px; height: '+h+'px');
                return dialog.resize(w, h);
            },
            onFailure: function(response) {
                alert("FAILURE (Error "+response.status+"): "+response.reponseText);
                Formize.Overlay.remove();
            }
        });
    },

    /* Close a virtual popup */
    close: function (dialog) {
        dialog = $(dialog);
        dialog.remove();
        Formize.Overlay.remove();
        return true;
    }


};


Formize.Partials = {

    refresh: function (event, element) {
        var dependents = element.readAttribute('data-dependents').split(',');
        var params = new Hash();
        if (element.value !== null && element.value !== undefined) {
            params.set(element.id, element.value);
            dependents.each(function(item) {
                // Replaces element
                item = $(item);
                if (item) {
                    var url = item.readAttribute('data-refresh');
                    if (url !== null) {
                        new Ajax.Request(url, {
                            method: 'get',
                            asynchronous:true,
                            evalScripts:true,
                            parameters: params,
                            onSuccess: function(response) {
                                item.replace(response.responseText);
                            },
                            onFailure: function(response) {
                                alert("ERROR FAILURE\n"+response.status+" "+response.statusText);
                            }
                        });
                    }
                }
            });
            return true;
        }
    },

    submitDialogForm: function(event, form) {
        var dialog_id = form.readAttribute('data-dialog');
        var dialog = $(dialog_id);

        var field = new Element('input', { type: 'hidden', name: 'dialog', value: dialog_id });
        form.insert(field);

        new Ajax.Request(form.readAttribute('action'), {
            method:      form.readAttribute('method') || 'post',
            parameters:  Form.serialize(form),
            asynchronous: true,
            evalScripts: true,
            onLoaded:  function(request){ form.fire("layout:change"); }, 
            onSuccess: function(request){
                if (request.responseJSON === null) {
                    // No return => validation error
                    dialog.update(request.responseText);
		    dialog.fire("layout:change");
                } else {
                    // Refresh element with its refresh URL
                    var updated =$(dialog.readAttribute('data-dialog-update'));
                    if (updated !== null) {
			var url = updated.readAttribute('data-refresh');
			new Ajax.Request(url, {
			    method: 'GET',
                            asynchronous:true,
                            evalScripts:true,
			    parameters: {selected: request.responseJSON.id},
			    onSuccess: function(request) { 
				updated.replace(request.responseText); 
				updated.fire("layout:change");
			    }
			});
                    }
                    // Close dialog
                    Formize.Dialog.close(dialog);
                }
            }
        });
        event.stop();
        return false;
    }

};


(function() {
    "use strict";

    document.on("change", "*[data-dependents]", Formize.Partials.refresh);

    document.on("click", "a[data-add-item]", function(event, element) {
        var list_id = element.readAttribute('data-add-item');
        var url = element.readAttribute('href');
        Formize.Dialog.open(url, list_id);
        event.stop();
    });

    document.on("click", "a[data-close-dialog]", function(event, element) {
        var dialog_id = element.readAttribute('data-close-dialog');
        Formize.Dialog.close(dialog_id);
        event.stop();
    });


    document.on("submit", "form[data-dialog]", Formize.Partials.submitDialogForm);

})();



/*
  function dyliChange(dyli, id) {
  var dyli_hf =$(dyli);
  var dyli_tf =$(dyli+'_tf');
  
  return new Ajax.Request(dyli_hf.getAttribute('href'), {
  method: 'get',
  parameters: {id: id},
  onSuccess: function(response) {
  var obj = response.responseJSON;
  if (obj!== null) {
  dyli_hf.value = obj.hf_value;
  dyli_tf.value = obj.tf_value;
  dyli_tf.size = (dyli_tf.value.length > 64 ? 64 : dyli_tf.value.length);
  }
  }
  });
  }


  function refreshList(select, request, source_url) {
  return new Ajax.Request(source_url, {
  method: 'get',
  parameters: {selected: request.responseJSON.id},
  onSuccess: function(response) {
  var list = $(select);
  list.update(response.responseText);
  }
  });
  }

  function refreshAutoList(dyli, request) {
  return dyliChange(dyli, request.responseJSON.id);
  }


  (function() {
  
  document.on("click", "a[data-new-item]", function(event, element) {
  var list_id = element.readAttribute('data-new-item');
  var url = element.readAttribute('href');
  openDialog(url, list_id);
  event.stop();
  });


  document.on("click", "a[data-dialog-open]", function(event, element) {
  var url = element.readAttribute('data-dialog-open');
  if (url === 'true') {
  url = element.readAttribute('href');
  }
  openDialog(url, element.readAttribute('data-dialog-update'));
  event.stop();
  });

  document.on("click", "a[data-dialog-close]", function(event, element) {
  var dialog_id = element.readAttribute('data-dialog-close');
  closeDialog(dialog_id);
  event.stop();
  });

  document.on("submit", "form[data-dialog]", function(event, form) {
  var dialog_id = form.readAttribute('data-dialog');
  var dialog = $(dialog_id);

  var field = new Element('input', { type: 'hidden', name: 'dialog', value: dialog_id });
  form.insert(field);

  new Ajax.Request(form.readAttribute('action'), {
  method:      form.readAttribute('method') || 'post',
  parameters:  Form.serialize(form),
  asynchronous: true,
  evalScripts: true,
  onLoaded:  function(request){ resizeDialog(dialog_id); }, 
  onSuccess: function(request){
  if (request.responseJSON === null) {
  // No return => validation error
  dialog.update(request.responseText).resize();
  } else {
  // Refresh list or execute call 
  var updated_id = dialog.readAttribute('data-dialog-update');
  var updated = $(updated_id);
  if (updated !== null) {
  if (updated.readAttribute('text_field_id') === null) {
  var url = updated.readAttribute('data-refresh');
  var parameter = updated.readAttribute('data-id-parameter-name');
  if (parameter === null) {
  parameter = 'selected';
  }
  var parameters = $H();
  parameters.set(parameter, request.responseJSON.id);
  if (url !== null) {
  new Ajax.Updater(updated_id, url, {
  method: 'GET',
  asynchronous:true,
  evalScripts:true,
  parameters: parameters,
  onSuccess:  function(request) { form.fire("layout:resize",  request); }
  });
  }
  } else {
  dyliChange(updated_id, request.responseJSON.id);
  }
  }
  // Close dialog
  closeDialog(dialog_id);
  }
  }
  });
  event.stop();
  return false;
  });



  })();
*/