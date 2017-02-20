require("fpHttp")
test_table = {a="@",b=2,c=3}
print(fpHttp.get("http://localhost/test.php?a=1"))
print(fpHttp.post("http://localhost/test.php",test_table))
