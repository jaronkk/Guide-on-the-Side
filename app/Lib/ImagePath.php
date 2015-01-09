<?php
/**
 * Methods fo handling uploaded images
 */
class ImagePath {
  /**
   * Replaces relative src attributes with absolute paths.  Optionally prepends the full base URL.
   *
   * @param string $html Text to search the phrase in
   * @param boolean $full If true, the full base URL will be prepended to the result.
   * @return string The modified html
   */
  public static function absolute_src($html, $full = false) {
    $image_pattern = '/(\<img[^>]* src\=")(uploads\/images\/[^\"]*"[^>]*\>)/';
    // Router::url() assumes this is being called from index.php.
    $prepend = Router::url('/', $full);
    $replacement_pattern = '$1' . $prepend . '$2';
    $html = preg_replace($image_pattern, $replacement_pattern, $html, -1, $count);
    // debug($html);
    // debug($count);
    return $html;
  }
}

?>
