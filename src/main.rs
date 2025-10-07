mod files;
#[link(name = "NotchHelper")] // defaults to dylib
unsafe extern "C" {
    fn show_status_item();
}

fn main() {
    unsafe {
        show_status_item();
    }
}

// fn get_files() -> Vec<String> {}
