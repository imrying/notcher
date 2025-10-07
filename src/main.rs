use std::env
use std::fmt


#[link(name = "NotchHelper")] // defaults to dylib
unsafe extern "C" {
    fn show_status_item();
}

const TMP_FOLDER_NAME = "TMPDIR";

fn main() {
    let TMP_FOLDER = env::var(TMP_FOLDER_NAME).expect(format!("Error: environment folder {} not present. Asserting", TMP_FOLDER_NAME).as_str());

    println!("{}", TMP_FOLDER);
    
    unsafe { show_status_item(); }
}
