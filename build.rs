use std::path::Path;

fn main() {
    // Tell rustc where to find our Swift-built .dylib
    println!("cargo:rustc-link-search=native={}", Path::new("macos").display());

    // Link the Swift helper (dynamic)
    println!("cargo:rustc-link-lib=NotchHelper");

    // Link macOS frameworks used by the Swift code
    println!("cargo:rustc-link-lib=framework=AppKit");
    println!("cargo:rustc-link-lib=framework=Foundation");
    // Cocoa is optional here since AppKit already pulls Foundation;
    // add if you include <Cocoa> in Swift:
    println!("cargo:rustc-link-lib=framework=Cocoa");
}

