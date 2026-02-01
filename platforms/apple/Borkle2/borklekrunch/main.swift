// main.swift: driver for borklekrunch

import Foundation
import Yams

let args = CommandLine.arguments

// expecting two arguments
guard args.count == 3 else {
    print("Usage: \(args[0]) input-basename output-file")
    print("    uses input-basename to derive bubble and a scene file name, then")
    print("    exports an ascii output file suitable (hopefully) for older")
    print("    systems")
    exit(1)
}

print("splunge")

