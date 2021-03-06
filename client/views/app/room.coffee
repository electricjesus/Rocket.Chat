# @TODO bug com o botão para "rolar até o fim" (novas mensagens) quando há uma mensagem com texto que gere rolagem horizontal
Template.room.helpers
	visible: ->
		console.log 'room.helpers visible' if window.rocketDebug
		return 'visible' if this._id is Session.get('openedRoom')

	tAddUsers: ->
		console.log 'room.helpers tAddUsers' if window.rocketDebug
		return t('Add_users')

	tQuickSearch: ->
		console.log 'room.helpers tQuickSearch' if window.rocketDebug
		return t('Quick_Search')

	favorite: ->
		console.log 'room.helpers favorite' if window.rocketDebug
		sub = ChatSubscription.findOne { rid: this._id }, { fields: { f: 1 } }
		return 'icon-star favorite-room' if sub?.f? and sub.f
		return 'icon-star-empty'

	subscribed: ->
		console.log 'room.helpers subscribed' if window.rocketDebug
		return ChatSubscription.find({ rid: this._id }).count() > 0

	messagesHistory: ->
		console.log 'room.helpers messagesHistory' if window.rocketDebug
		return ChatMessage.find { rid: this._id, t: { '$ne': 't' }  }, { sort: { ts: 1 } }

	hasMore: ->
		console.log 'room.helpers hasMore' if window.rocketDebug
		return RoomHistoryManager.hasMore this._id

	isLoading: ->
		console.log 'room.helpers isLoading' if window.rocketDebug
		return 'btn-loading' if RoomHistoryManager.isLoading this._id

	windowId: ->
		console.log 'room.helpers windowId' if window.rocketDebug
		return "chat-window-#{this._id}"

	usersTyping: ->
		console.log 'room.helpers usersTyping' if window.rocketDebug
		users = MsgTyping.get @_id
		if users.length is 0
			return
		if users.length is 1
			return {
				multi: false
				selfTyping: MsgTyping.selfTyping.get()
				users: users[0]
			}

		# usernames = _.map messages, (message) -> return message.u.username

		last = users.pop()
		if users.length > 4
			last = t('others')
		# else
		usernames = users.join(', ')
		usernames = [usernames, last]
		return {
			multi: true
			selfTyping: MsgTyping.selfTyping.get()
			users: usernames.join " #{t 'and'} "
		}

	roomName: ->
		console.log 'room.helpers roomName' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData

		if roomData.t is 'd'
			return ChatSubscription.findOne({ rid: this._id }, { fields: { name: 1 } })?.name
		else
			return roomData.name

	roomIcon: ->
		console.log 'room.helpers roomIcon' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData?.t

		switch roomData.t
			when 'd' then return 'icon-at'
			when 'c' then return 'icon-hash'
			when 'p' then return 'icon-lock'

	userData: ->
		console.log 'room.helpers userData' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)

		return {} unless roomData

		if roomData.t is 'd'
			username = _.without roomData.usernames, Meteor.user().username
			UserManager.addUser username

			userData = {
				name: Session.get('user_' + username + '_name')
				emails: Session.get('user_' + username + '_emails') || []
				phone: Session.get('user_' + username + '_phone')
				username: String(username)
			}
			return userData

	userStatus: ->
		console.log 'room.helpers userStatus' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)

		return {} unless roomData

		if roomData.t is 'd'
			username = _.without roomData.usernames, Meteor.user().username
			return Session.get('user_' + username + '_status') || 'offline'

		else
			return 'offline'

	autocompleteSettingsAddUser: ->
		console.log 'room.helpers autocompleteSettingsAddUser' if window.rocketDebug
		return {
			limit: 10
			# inputDelay: 300
			rules: [
				{
					collection: 'UserAndRoom'
					subscription: 'roomSearch'
					field: 'name'
					template: Template.roomSearch
					noMatchTemplate: Template.roomSearchEmpty
					matchAll: true
					filter: { type: 'u', uid: { $ne: Meteor.userId() } }
					sort: 'name'
				}
			]
		}

	autocompleteSettingsRoomSearch: ->
		console.log 'room.helpers autocompleteSettingsRoomSearch' if window.rocketDebug
		return {
			limit: 10
			# inputDelay: 300
			rules: [
				{
					collection: 'UserAndRoom'
					subscription: 'roomSearch'
					field: 'name'
					template: Template.roomSearch
					noMatchTemplate: Template.roomSearchEmpty
					matchAll: true
					filter: { uid: { $ne: Meteor.userId() } }
					sort: 'name'
				}
			]
		}

	isChannel: ->
		console.log 'room.helpers isChannel' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData
		return roomData.t is 'c'

	canAddUser: ->
		console.log 'room.helpers canAddUser' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData
		return roomData.t in ['p', 'c'] and roomData.u?._id is Meteor.userId()

	canEditName: ->
		console.log 'room.helpers canEditName' if window.rocketDebug
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData
		return roomData.u?._id is Meteor.userId() and roomData.t in ['c', 'p']

	roomNameEdit: ->
		console.log 'room.helpers roomNameEdit' if window.rocketDebug
		return Session.get('roomData' + this._id)?.name

	editingTitle: ->
		console.log 'room.helpers editingTitle' if window.rocketDebug
		return 'hidden' if Session.get('editRoomTitle')

	showEditingTitle: ->
		console.log 'room.helpers showEditingTitle' if window.rocketDebug
		return 'hidden' if not Session.get('editRoomTitle')

	flexOpened: ->
		console.log 'room.helpers flexOpened' if window.rocketDebug
		return 'opened' if Session.equals('flexOpened', true)

	arrowPosition: ->
		console.log 'room.helpers arrowPosition' if window.rocketDebug
		return 'left' unless Session.equals('flexOpened', true)

	phoneNumber: ->
		console.log 'room.helpers phoneNumber' if window.rocketDebug
		return '' unless this.phoneNumber
		if this.phoneNumber.length > 10
			return "(#{this.phoneNumber.substr(0,2)}) #{this.phoneNumber.substr(2,5)}-#{this.phoneNumber.substr(7)}"
		else
			return "(#{this.phoneNumber.substr(0,2)}) #{this.phoneNumber.substr(2,4)}-#{this.phoneNumber.substr(6)}"

	isGroupChat: ->
		console.log 'room.helpers isGroupChat' if window.rocketDebug
		room = ChatRoom.findOne(this._id, { reactive: false })
		return room?.t in ['c', 'p']

	userActiveByUsername: (username) ->
		console.log 'room.helpers userActiveByUsername' if window.rocketDebug
		status = Session.get 'user_' + username + '_status'
		if status in ['online', 'away', 'busy']
			return {username: username, status: status}
		return

	roomUsers: ->
		console.log 'room.helpers roomUsers' if window.rocketDebug
		room = ChatRoom.findOne(this._id, { reactive: false })
		ret =
			_id: this._id
			total: room?.usernames.length
			totalOnline: 0
			users: room.usernames

		return ret

	flexUserInfo: ->
		console.log 'room.helpers flexUserInfo' if window.rocketDebug
		username = Session.get('showUserInfo')

		userData = {
			# name: Session.get('user_' + uid + '_name')
			# emails: Session.get('user_' + uid + '_emails')
			username: String(username)
		}
		# phone = Session.get('user_' + uid + '_phone')
		# if phone? and phone[0]?.phoneNumber
		# 	userData.phone = phone[0]?.phoneNumber

		return userData

	seeAll: ->
		console.log 'room.helpers seeAll' if window.rocketDebug
		if Template.instance().showUsersOffline.get()
			return t('See_only_online')
		else
			return t('See_all')

	getPupupConfig: ->
		console.log 'room.helpers getPupupConfig' if window.rocketDebug
		template = Template.instance()
		return {
			getInput: ->
				return template.find('.input-message')
		}

	remoteVideoUrl: ->
		return Session.get('remoteVideoUrl')

	selfVideoUrl: ->
		return Session.get('selfVideoUrl')

	flexOpenedRTC1: ->
		console.log 'room.helpers flexOpenedRTC1' if window.rocketDebug
		return 'layout1' if Session.equals('flexOpenedRTC1', true)

	flexOpenedRTC2: ->
		console.log 'room.helpers flexOpenedRTC2' if window.rocketDebug
		return 'layout2' if Session.equals('flexOpenedRTC2', true)
	rtcLayout1: ->
		return (Session.get('rtcLayoutmode') == 1 ? true: false);

	rtcLayout2: ->
		return (Session.get('rtcLayoutmode') == 2 ? true: false);

	rtcLayout3: ->
		return (Session.get('rtcLayoutmode') == 3 ? true: false);

	noRtcLayout: ->
		return (!Session.get('rtcLayoutmode') || (Session.get('rtcLayoutmode') == 0) ? true: false);



Template.room.events

	"click .flex-tab .more": (event) ->
		console.log 'room click .flex-tab .more' if window.rocketDebug
		if (Session.get('flexOpened'))
			Session.set('rtcLayoutmode', 0)
			Session.set('flexOpened',false)
		else
			Session.set('flexOpened', true)


	"click .flex-tab  .video-remote" : (e) ->
		console.log 'room click .flex-tab .video-remote' if window.rocketDebug
		if (Session.get('flexOpened'))
			if (!Session.get('rtcLayoutmode'))
				Session.set('rtcLayoutmode', 1)
			else
				t = Session.get('rtcLayoutmode')
				t = (t + 1) % 4
				console.log  'setting rtcLayoutmode to ' + t  if window.rocketDebug
				Session.set('rtcLayoutmode', t)

	"click .flex-tab  .video-self" : (e) ->
		console.log 'room click .flex-tab .video-self' if window.rocketDebug
		if (Session.get('rtcLayoutmode') == 3)
			console.log 'video-self clicked in layout3' if window.rocketDebug
			i = document.getElementById("fullscreendiv")
			if i.requestFullscreen
				i.requestFullscreen()
			else
				if i.webkitRequestFullscreen
					i.webkitRequestFullscreen()
				else
					if i.mozRequestFullScreen
						i.mozRequestFullScreen()
					else
						if i.msRequestFullscreen
							i.msRequestFullscreen()



	'click .chat-new-messages': (event) ->
		console.log 'room click .chat-new-messages' if window.rocketDebug
		# chatMessages = $('#chat-window-' + this._id + ' .messages-box .wrapper')
		# chatMessages.animate({scrollTop: chatMessages[0].scrollHeight}, 'normal')
		$('#chat-window-' + FlowRouter.getParam('_id') + ' .input-message').focus()

	'click .toggle-favorite': (event) ->
		console.log 'room click .toggle-favorite' if window.rocketDebug
		event.stopPropagation()
		event.preventDefault()
		Meteor.call 'toogleFavorite', FlowRouter.getParam('_id'), !$('i', event.currentTarget).hasClass('favorite-room')

	'click .join': (event) ->
		console.log 'room click .join' if window.rocketDebug
		event.stopPropagation()
		event.preventDefault()
		Meteor.call 'joinRoom', FlowRouter.getParam('_id')

	"click .burger": ->
		console.log 'room click .burger' if window.rocketDebug
		chatContainer = $("#rocket-chat")
		if chatContainer.hasClass("menu-closed")
			chatContainer.removeClass("menu-closed").addClass("menu-opened")
		else
			chatContainer.addClass("menu-closed").removeClass("menu-opened")

	'focus .input-message': (event) ->
		console.log 'room focus .input-message' if window.rocketDebug
		KonchatNotification.removeRoomNotification(FlowRouter.getParam('_id'))

	'keyup .input-message': (event) ->
		console.log 'room keyup .input-message',FlowRouter.getParam('_id') if window.rocketDebug
		ChatMessages.keyup(FlowRouter.getParam('_id'), event, Template.instance())

	'keydown .input-message': (event) ->
		console.log 'room keydown .input-message',FlowRouter.getParam('_id') if window.rocketDebug
		ChatMessages.keydown(FlowRouter.getParam('_id'), event, Template.instance())

	# 'keydown .input-message-editing': (event) ->
	# 	console.log 'room keydown .input-message-editing',this._id if window.rocketDebug
	# 	ChatMessages.keydownEditing(this._id, event)

	# 'blur .input-message-editing': (event) ->
	# 	console.log 'room blur keydown blur .input-message-editing',this._id if window.rocketDebug
	# 	ChatMessages.stopEditingLastMessage()

	'click .message-form .icon-paper-plane': (event) ->
		console.log 'room click .message-form .icon-paper-plane' if window.rocketDebug
		input = $(event.currentTarget).siblings("textarea")
		ChatMessages.send(FlowRouter.getParam('_id'), input.get(0))

	'click .add-user': (event) ->
		console.log 'room click click .add-user' if window.rocketDebug
		toggleAddUser()

	'click .edit-room-title': (event) ->
		console.log 'room click .edit-room-title' if window.rocketDebug
		event.preventDefault()
		Session.set('editRoomTitle', true)
		$(".fixed-title").addClass "visible"
		Meteor.setTimeout ->
			$('#room-title-field').focus().select()
		, 10

	'keydown #user-add-search': (event) ->
		console.log 'room keydown #user-add-search' if window.rocketDebug
		if event.keyCode is 27 # esc
			toggleAddUser()

	'keydown #room-title-field': (event) ->
		console.log 'room keydown #room-title-field' if window.rocketDebug
		if event.keyCode is 27 # esc
			Session.set('editRoomTitle', false)
		else if event.keyCode is 13 # enter
			renameRoom FlowRouter.getParam('_id'), $(event.currentTarget).val()

	'blur #room-title-field': (event) ->
		console.log 'room blur #room-title-field' if window.rocketDebug
		# TUDO: create a configuration to select the desired behaviour
		# renameRoom this._id, $(event.currentTarget).val()
		Session.set('editRoomTitle', false)
		$(".fixed-title").removeClass "visible"

	"click .flex-tab .user-image > a" : (e) ->
		console.log 'room click .flex-tab .user-image > a' if window.rocketDebug
		Session.set('flexOpened', true)
		Session.set('showUserInfo', $(e.currentTarget).data('username'))

	'click .user-card-message': (e) ->
		console.log 'room click .user-card-message' if window.rocketDebug
		roomData = Session.get('roomData' + this._arguments[1].rid)
		if roomData.t in ['c', 'p']
			Session.set('flexOpened', true)
			Session.set('showUserInfo', $(e.currentTarget).data('username'))
		else
			Session.set('flexOpened', true)

	'click .user-view nav .back': (e) ->
		console.log 'room click .user-view nav .back' if window.rocketDebug
		Session.set('showUserInfo', null)

	'click .user-view nav .pvt-msg': (e) ->
		console.log 'room click .user-view nav .pvt-msg' if window.rocketDebug
		Meteor.call 'createDirectMessage', Session.get('showUserInfo'), (error, result) ->
			if error
				return Errors.throw error.reason

			if result?.rid?
				FlowRouter.go('room', { _id: result.rid })

	'click button.load-more': (e) ->
		console.log 'room click button.load-more' if window.rocketDebug
		RoomHistoryManager.getMore FlowRouter.getParam('_id')

	'autocompleteselect #user-add-search': (event, template, doc) ->
		console.log 'room autocompleteselect #user-add-search' if window.rocketDebug
		roomData = Session.get('roomData' + Session.get('openedRoom'))

		if roomData.t is 'd'
			Meteor.call 'createGroupRoom', roomData.usernames, doc.username, (error, result) ->
				if error
					return Errors.throw error.reason

				if result?.rid?
					# FlowRouter.go('room', { _id: result.rid })
					$('#user-add-search').val('')
		else if roomData.t in ['c', 'p']
			Meteor.call 'addUserToRoom', { rid: roomData._id, username: doc.username }, (error, result) ->
				if error
					return Errors.throw error.reason

				$('#user-add-search').val('')
				toggleAddUser()

	'autocompleteselect #room-search': (event, template, doc) ->
		console.log 'room autocompleteselect #room-search' if window.rocketDebug
		if doc.type is 'u'
			Meteor.call 'createDirectMessage', doc.uid, (error, result) ->
				if error
					return Errors.throw error.reason

				if result?.rid?
					FlowRouter.go('room', { _id: result.rid })
					$('#room-search').val('')
		else
			FlowRouter.go('room', { _id: doc.rid })
			$('#room-search').val('')

	# 'scroll .wrapper': (e, instance) ->
		# console.log 'room scroll .wrapper' if window.rocketDebug
		# if e.currentTarget.offsetHeight + e.currentTarget.scrollTop < e.currentTarget.scrollHeight
		# 	instance.scrollOnBottom = false
		# else
		# 	instance.scrollOnBottom = true
		# 	$('.new-message').addClass('not')

	'click .new-message': (e) ->
		console.log 'room click .new-message' if window.rocketDebug
		Template.instance().atBottom = true
		Template.instance().find('.input-message').focus()

	'click .see-all': (e, instance) ->
		console.log 'room click .see-all' if window.rocketDebug
		instance.showUsersOffline.set(!instance.showUsersOffline.get())

	"mousedown .edit-message": (e) ->
		ChatMessages.edit(e.currentTarget.parentNode.parentNode)
		# Session.set 'editingMessageId', undefined
		# Meteor.defer ->
		# 	Session.set 'editingMessageId', self._id
		# 	Meteor.defer ->
		# 		$('.input-message-editing').select()

	"click .mention-link": (e) ->
		Session.set('flexOpened', true)
		Session.set('showUserInfo', $(e.currentTarget).data('username'))

	'click .delete-message': (event) ->
		msg = event.currentTarget.parentNode.parentNode
		return if msg.classList.contains("system")
		swal {
			title: t('Are_you_sure')
			text: t('You_will_not_be_able_to_recover')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		}, ->
			swal t('Deleted'), t('Your_entry_has_been_deleted'), 'success'
			ChatMessages.deleteMsg(msg)

	'click .start-video': (event) ->
		webrtc.to = FlowRouter.getParam('_id').replace(Meteor.userId(), '')
		webrtc.room = FlowRouter.getParam('_id')
		webrtc.start(true)

	'click .stop-video': (event) ->
		webrtc.stop()

	'dragenter #dropzone': (e) ->
		console.log 'DRAG ENTER'

	'dragleave #dropzone': (e) ->
		console.log 'DRAG OUT'

	'dropped #dropzone': (e) ->
		console.log 'room dropped #dropzone' if window.rocketDebug
		FS?.Utility?.eachFile e, (file) ->
			newFile = new (FS.File)(file)
			newFile.rid = Session.get('openedRoom')
			Files.insert newFile, (error, fileObj) ->
				unless error
					toastr.success 'Upload succeeded!'
					console.log('room fileObj', fileObj) if window.rocketDebug
					Meteor.call 'sendMessage',
						_id: Random.id()
						rid: fileObj.rid
						msg: 'File Uploaded: *' + fileObj.original.name + '* \n' + document.location.origin + '/cfs/files/Files/' + fileObj._id
						file:
							_id: fileObj._id

Template.room.onCreated ->
	console.log 'room.onCreated' if window.rocketDebug
	# this.scrollOnBottom = true
	# this.typing = new msgTyping this.data._id
	this.showUsersOffline = new ReactiveVar false
	this.atBottom = true

Template.room.onRendered ->
	console.log 'room.onRendered' if window.rocketDebug
	FlexTab.check()
	ChatMessages.init()
	# ScrollListener.init()

	wrapper = this.find('.wrapper')
	newMessage = this.find(".new-message")

	template = this
	onscroll = ->
		template.atBottom = wrapper.scrollTop is wrapper.scrollHeight - wrapper.clientHeight

	Meteor.setInterval ->
		if template.atBottom
			wrapper.scrollTop = wrapper.scrollHeight - wrapper.clientHeight
			newMessage.className = "new-message not"
	, 100

	wrapper.addEventListener 'mousewheel', ->
		template.atBottom = false
		onscroll()

	wrapper.addEventListener 'wheel', ->
		template.atBottom = false
		onscroll()

	console.log 'room.rendered' if window.rocketDebug
	# salva a data da renderização para exibir alertas de novas mensagens
	$.data(this.firstNode, 'renderedAt', new Date)

	webrtc.onRemoteUrl = (url) ->
		Session.set('flexOpened', true)
		Session.set('remoteVideoUrl', url)

	webrtc.onSelfUrl = (url) ->
		Session.set('flexOpened', true)
		Session.set('selfVideoUrl', url)

	RoomHistoryManager.getMoreIfIsEmpty this.data._id

renameRoom = (rid, name) ->
	console.log 'room renameRoom' if window.rocketDebug
	if Session.get('roomData' + rid).name == name
		Session.set('editRoomTitle', false)
		return false

	Meteor.call 'saveRoomName', rid, name, (error, result) ->
		if result
			Session.set('editRoomTitle', false)

			toastr.success t('Room_name_changed_successfully')
		if error
			toastr.error error.reason

toggleAddUser = ->
	console.log 'room toggleAddUser' if window.rocketDebug
	btn = $('.add-user')
	$('.add-user-search').toggleClass('show-search')
	if $('i', btn).hasClass('icon-plus')
		$('#user-add-search').focus()
		$('i', btn).removeClass('icon-plus').addClass('icon-cancel')
	else
		$('#user-add-search').val('')
		$('i', btn).removeClass('icon-cancel').addClass('icon-plus')
