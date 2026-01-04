extends Node

class_name TestSuite

var current_test_passed: bool = true
var current_test_error: String = ""
var results: Array[Dictionary] = []
var passed_count: int = 0
var failed_count: int = 0

func run_all_tests() -> void:
	passed_count = 0
	failed_count = 0
	results.clear()
	
	var method_list = get_method_list()
	for method in method_list:
		if method.name.begins_with("test_"):
			_run_test(Callable(self, method.name))

func _run_test(test_callable: Callable) -> void:
	current_test_passed = true
	current_test_error = ""
	
	print("Running test: ", test_callable.get_method())
	
	test_callable.call()
	
	var result = {
		"name": test_callable.get_method(),
		"passed": current_test_passed,
		"error": current_test_error
	}
	
	if current_test_passed:
		passed_count += 1
		print("  PASSED")
	else:
		failed_count += 1
		print("  FAILED: ", current_test_error)
	
	results.append(result)

func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		_fail("Expected true, but got false. " + message)

func assert_eq(actual, expected, message: String = "") -> void:
	if typeof(actual) != typeof(expected):
		_fail("Type mismatch: actual is %s, expected is %s. %s" % [type_string(typeof(actual)), type_string(typeof(expected)), message])
		return
	if actual != expected:
		_fail("Expected %s, but got %s. %s" % [str(expected), str(actual), message])

func assert_ne(actual, expected, message: String = "") -> void:
	if actual == expected:
		_fail("Expected %s to not equal %s. %s" % [str(actual), str(expected), message])

func _fail(message: String) -> void:
	current_test_passed = false
	current_test_error = message
	push_error(message)
