mod files;
#[link(name = "NotchHelper")] // defaults to dylib
unsafe extern "C" {
    fn show_status_item();
}

fn main() {
    files::init_notch_path();

    unsafe {
        show_status_item();
    }
}

// fn get_files() -> Vec<String> {}
