mod ffi;
pub mod ffi_structs;
mod files;

pub use ffi::{free_string_array, get_files_from_notch, init_notch};
