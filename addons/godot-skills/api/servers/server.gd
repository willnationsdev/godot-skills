extends Node
class_name GDSServer

var queue := []

func submit(p_req):
    queue.append(p_req)

func _process_requests():
    queue.clear()