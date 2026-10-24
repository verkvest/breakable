extends Node

# GodotNotificationCenter
# https://github.com/didier-v/GodotNotificationCenter
# Written by Didier Vandekerckhove
# licence: MIT

var notifications: Dictionary = {}


func _ready() -> void:
	notifications = {}


func post_notification(notification_name: String, notification_data) -> void:
	if not notifications.has(notification_name):
		return
	var current_observers: Dictionary = notifications[notification_name].observers
	for id in current_observers.keys():
		var an_observer: Dictionary = current_observers[id]
		var obj = an_observer.object
		if is_instance_valid(obj) and obj.has_method(an_observer.action):
			obj.call(an_observer.action, obj, notification_name, notification_data)


func add_observer(observer: Object, notification_name: String, action: String) -> void:
	if not notifications.has(notification_name):
		notifications[notification_name] = {"observers": {}}
	var current_observers: Dictionary = notifications[notification_name].observers
	current_observers[observer.get_instance_id()] = {
		"object": observer,
		"action": action,
	}


func remove_observer(observer: Object, notification_name: String) -> void:
	if not notifications.has(notification_name):
		return
	var current_observers: Dictionary = notifications[notification_name].observers
	var id := observer.get_instance_id()
	if current_observers.has(id):
		current_observers.erase(id)
