return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      -- file and directory options
      dir_path = "assets", ---@type string | fun(): string
      extension = "png", ---@type string | fun(): string
      file_name = "%Y-%m-%d-%H-%M-%S", ---@type string | fun(): string
      use_absolute_path = false, ---@type boolean | fun(): boolean
      relative_to_current_file = true, ---@type boolean | fun(): boolean

      -- template options
      template = "$FILE_PATH", ---@type string | fun(context: table): string
      url_encode_path = false, ---@type boolean | fun(): boolean
      relative_template_path = true, ---@type boolean | fun(): boolean
      use_cursor_in_template = true, ---@type boolean | fun(): boolean
      insert_mode_after_paste = true, ---@type boolean | fun(): boolean

      -- prompt options
      prompt_for_file_name = true, ---@type boolean | fun(): boolean
      show_dir_path_in_prompt = false, ---@type boolean | fun(): boolean

      -- base64 options
      max_base64_size = 10, ---@type number | fun(): number
      embed_image_as_base64 = false, ---@type boolean | fun(): boolean

      -- image options
      process_cmd = "", ---@type string | fun(): string
      copy_images = false, ---@type boolean | fun(): boolean
      download_images = true, ---@type boolean | fun(): boolean

      -- drag and drop options
      drag_and_drop = {
        enabled = true, ---@type boolean | fun(): boolean
        insert_mode = false, ---@type boolean | fun(): boolean
      },

      -- -- Set the extension that the image file will have
      -- -- I'm also specifying the image options with the `process_cmd`
      -- -- Notice that I HAVE to convert the images to the desired format
      -- -- If you don't specify the output format, you won't see the size decrease

      -- extension = "avif", ---@type string
      -- process_cmd = "convert - -quality 75 avif:-", ---@type string

      -- extension = "webp", ---@type string
      -- process_cmd = "convert - -quality 75 webp:-", ---@type string

      -- extension = "png", ---@type string
      -- process_cmd = "convert - -quality 75 png:-", ---@type string

      -- extension = "jpg", ---@type string
      -- process_cmd = "convert - -quality 75 jpg:-", ---@type string

      -- -- Here are other conversion options to play around
      -- -- Notice that with this other option you resize all the images
      -- process_cmd = "convert - -quality 75 -resize 50% png:-", ---@type string

      -- -- Other parameters I found in stackoverflow
      -- -- https://stackoverflow.com/a/27269260
      -- --
      -- -- -depth value
      -- -- Color depth is the number of bits per channel for each pixel. For
      -- -- example, for a depth of 16 using RGB, each channel of Red, Green, and
      -- -- Blue can range from 0 to 2^16-1 (65535). Use this option to specify
      -- -- the depth of raw images formats whose depth is unknown such as GRAY,
      -- -- RGB, or CMYK, or to change the depth of any image after it has been read.
      -- --
      -- -- compression-filter (filter-type)
      -- -- compression level, which is 0 (worst but fastest compression) to 9 (best but slowest)
      -- process_cmd = "convert - -depth 24 -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 png:-",
      --
      -- -- These are for jpegs
      -- process_cmd = "convert - -sampling-factor 4:2:0 -strip -interlace JPEG -colorspace RGB -quality 75 jpg:-",
      -- process_cmd = "convert - -strip -interlace Plane -gaussian-blur 0.05 -quality 75 jpg:-",
      --
    },

    -- filetype specific options
    filetypes = {
      markdown = {
        url_encode_path = true, ---@type boolean | fun(): boolean
        template = "![$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
        download_images = false, ---@type boolean | fun(): boolean
      },

      vimwiki = {
        url_encode_path = true, ---@type boolean | fun(): boolean
        template = "![$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
        download_images = false, ---@type boolean | fun(): boolean
      },

      html = {
        template = '<img src="$FILE_PATH" alt="$CURSOR">', ---@type string | fun(context: table): string
      },

      tex = {
        relative_template_path = false, ---@type boolean | fun(): boolean
        template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
    ]], ---@type string | fun(context: table): string
      },

      typst = {
        template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
    ]], ---@type string | fun(context: table): string
      },

      rst = {
        template = [[
.. image:: $FILE_PATH
   :alt: $CURSOR
   :width: 80%
    ]], ---@type string | fun(context: table): string
      },

      asciidoc = {
        template = 'image::$FILE_PATH[width=80%, alt="$CURSOR"]', ---@type string | fun(context: table): string
      },

      org = {
        template = [=[
#+BEGIN_FIGURE
[[file:$FILE_PATH]]
#+CAPTION: $CURSOR
#+NAME: fig:$LABEL
#+END_FIGURE
    ]=], ---@type string | fun(context: table): string
      },
    },

    -- file, directory, and custom triggered options
    files = {}, ---@type table | fun(): table
    dirs = {}, ---@type table | fun(): table
    custom = {}, ---@type table | fun(): table
  },
  keys = {
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
