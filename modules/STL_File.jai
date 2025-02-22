
modified_at :: (file: string) -> int {
  file_stat: stat_t;
  statin := stat(temp_c_string(file), *file_stat);
  if statin != 0 {
    return 0;
  } else {
    return file_stat.st_mtime.tv_sec;
  }
}


#import "POSIX";
#import "Basic";