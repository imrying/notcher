use std::path::Path;

fn main() {
    // Path to Swift-built .dylib
    println!(
        "cargo:rustc-link-search=native={}",
        Path::new(".build/debug").display()
    );

    // Link the Swift helper (dynamic)
    println!("cargo:rustc-link-lib=dylib=NotchHelper");

    // Link macOS frameworks used by the Swift code
    println!("cargo:rustc-link-lib=framework=AppKit");
    println!("cargo:rustc-link-lib=framework=Foundation");
    println!("cargo:rustc-link-lib=framework=Cocoa");
}
