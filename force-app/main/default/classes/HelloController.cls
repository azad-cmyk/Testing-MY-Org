public with sharing class HelloController {

    public String message {get; set;}

    public HelloController(){
        message = 'Click the button to call Apex method';
    }

    public void sayHello(){
        message = 'Hello from Apex Method!';
    }
}