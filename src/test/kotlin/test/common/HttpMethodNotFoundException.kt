package test.common

class HttpMethodNotFoundException(method: String) : IllegalArgumentException(("Http method \"${method}\" not found"))
