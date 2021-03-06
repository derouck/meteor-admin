# Add hooks used by many forms
AutoForm.addHooks [
		'admin_insert',
		'admin_update',
		'admin_translate',
		'adminNewUser',
		'adminUpdateUser',
		'adminSendResetPasswordEmail',
		'adminChangePassword'],
	beginSubmit: ->
		$('.btn-primary').addClass('disabled')
	endSubmit: ->
		$('.btn-primary').removeClass('disabled')
	onError: (formType, error)->
		console.log('something went wrong')
		AdminDashboard.alertFailure error.message

AutoForm.hooks
	admin_insert:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			hook = @
			Meteor.call 'adminInsertDoc', insertDoc, Session.get('admin_collection_name'), (e,r)->
				if e
					hook.done(e)
				else
					adminCallback 'onInsert', [Session.get 'admin_collection_name', insertDoc, updateDoc, currentDoc], (collection) ->
						hook.done null, collection
			return false
		onSuccess: (formType, collection)->
			AdminDashboard.alertSuccess 'Successfully created'
			Router.go "/admin/#{collection}"

	admin_update:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			console.log('admin_update submit_hook')
			hook = @
			Meteor.call 'adminUpdateDoc', updateDoc, Session.get('admin_collection_name'), Session.get('admin_id'), (e,r)->
				if e
					hook.done(e)
				else
					adminCallback 'onUpdate', [Session.get 'admin_collection_name', insertDoc, updateDoc, currentDoc], (collection) ->
						hook.done null, collection
			return false
		onSuccess: (formType, collection)->
			AdminDashboard.alertSuccess 'Successfully updated'
			Router.go "/admin/#{collection}"

	admin_translate:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			console.log('admin_translate submit_hook')
			hook = @
			Meteor.call 'adminNewTranslationDoc', updateDoc, Session.get('admin_collection_name'), Session.get('admin_id'), Session.get('language_code'), (e,r)->
				if e
					console.log('translate meteor method call error: ' + e)
					hook.done(e)
				else
					console.log('translate meteor method call success: ' )

					#TODO: Do we need to have an alternative callback here?
					adminCallback 'onUpdate', [Session.get 'admin_collection_name', insertDoc, updateDoc, currentDoc], (collection) ->
						hook.done null, collection
			return false
		onSuccess: (formType, collection)->
			AdminDashboard.alertSuccess 'Successfully translated (' + Session.get('language_code') + ')'
			TAPi18n.setLanguage('en')
			Router.go "/admin/#{collection}"

	adminNewUser:
		onSuccess: (formType, result)->
			AdminDashboard.alertSuccess 'Created user'
			Router.go '/admin/Users'

	adminUpdateUser:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminUpdateUser', updateDoc, Session.get('admin_id'), @done
			return false
		onSuccess: (formType, result)->
			AdminDashboard.alertSuccess 'Updated user'
			Router.go '/admin/Users'

	adminSendResetPasswordEmail:
		onSuccess: (formType, result)->
			AdminDashboard.alertSuccess 'Email sent'

	adminChangePassword:
		onSuccess: (operation, result, template)->
			AdminDashboard.alertSuccess 'Password reset'
