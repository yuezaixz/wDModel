//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

protocol FullyNamed {
    var fullName:String{get}
}

class Person :FullyNamed {
    var fullName:String
    init(fullName:String){
        self.fullName = fullName
    }
}

let david = Person(fullName: "David")
print(david.fullName)
david.fullName = "TTTTT"
print(david.fullName)

