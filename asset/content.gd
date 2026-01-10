extends Node
class_name cardCont
var file_path="res://asset/content.csv"#定义读取路径
static  var conDict:Dictionary#定义字典

func _init() -> void:
	conDict=read_csv_as_nested_dict(file_path)
#初始化，以使用后面定义的函数，获取数据
func read_csv_as_nested_dict(path:String)->Dictionary:
	var data={}
	var file=FileAccess.open(path,FileAccess.READ)#读取给出的路径下的csv表格
	var headers=[]
	var first_line=true
	while not file.eof_reached():#确认识别是否到达csv表格底部
		var values =file.get_csv_line()#获取表格信息
		if first_line :
			headers=values
			first_line=false
		elif values.size()>=2:
			var key =values[0]
			var row_dict={}
			for i in range(0,headers.size()):
				row_dict[headers[i]]=values[i]
			data[key]=row_dict
	file.close()
	return data
