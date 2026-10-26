// Server: dead placeholder image URLs that used to be seeded as "default" profile pictures
// (Match's server-side default profile, Twitter's old client-side fallback) before both were
// removed in favour of ProfileAvatar's own grey-circle-with-user-icon state. Profiles created
// before that fix may still have one of these saved - filtered out here so they render as "no
// image" instead of loading a literal "no image available" placeholder graphic.
const KNOWN_PLACEHOLDER_IMAGE_URLS = [
  'https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg',
  'https://i.fivemanage.com/images/3ClWwmpwkFhL.png',
];

export const stripPlaceholderImageUrl = (url?: string | null): string =>
  url && !KNOWN_PLACEHOLDER_IMAGE_URLS.includes(url) ? url : '';
