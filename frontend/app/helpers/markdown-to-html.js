import { helper } from '@ember/component/helper';
import MarkdownIt from 'markdown-it';

export default helper(function markdownToHtml([markdown]) {
  const md = new MarkdownIt();
  return md.render(markdown);
});
