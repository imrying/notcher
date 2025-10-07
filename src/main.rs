use std::env;
use std::fs::create_dir;
use std::path::{Path, PathBuf};

#[link(name = "NotchHelper")] // defaults to dylib
unsafe extern "C" {
    fn show_status_item();
}

const TMP_FOLDER_NAME: &str = "TMPDIR";
const NOTCH_FOLDER: &str = "notch";

fn create_or_get_dir(tmp_folder: &'static str, notch_folder: &'static str) -> PathBuf {
    let tmp_folder = env::var(tmp_folder)
        .unwrap_or_else(|_| panic!("Error no enviroment folder found for {}", tmp_folder));

    let tmp_path = Path::new(&tmp_folder);
    let notch_path = tmp_path.join(notch_folder);

    println!("{:?}", notch_path);
    if !notch_path.exists() {
        create_dir(&notch_path)
            .unwrap_or_else(|_| panic!("Error could not create folder in {}", tmp_folder));
    }

    notch_path
}

fn main() {
    let notch_path = create_or_get_dir(TMP_FOLDER_NAME, NOTCH_FOLDER);

    unsafe {
        show_status_item();
    }
}

// fn get_files() -> Vec<String> {}
