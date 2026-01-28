// main.swift: borkle1-conv's driver program

import Foundation


let args = CommandLine.arguments

// expecting two arguments
guard args.count == 3 else {
    print("Usage: \(args[0]) file.borkle output-basename")
    exit(1)
}

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])

print(inputURL, outputURL)




