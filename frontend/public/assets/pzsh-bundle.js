(()=>{var X=typeof window!="undefined"&&window.customElements!=null&&window.customElements.polyfillWrapFlushCallback!==void 0;var C=(r,e,t=null)=>{for(;e!==t;){let s=e.nextSibling;r.removeChild(e),e=s}};var y=`{{lit-${String(Math.random()).slice(2)}}}`,Z=`<!--${y}-->`,Se=new RegExp(`${y}|${Z}`),R="$lit$",M=class{constructor(e,t){this.parts=[],this.element=t;let s=[],n=[],o=document.createTreeWalker(t.content,133,null,!1),i=0,a=-1,c=0,{strings:u,values:{length:g}}=e;for(;c<g;){let l=o.nextNode();if(l===null){o.currentNode=n.pop();continue}if(a++,l.nodeType===1){if(l.hasAttributes()){let b=l.attributes,{length:q}=b,P=0;for(let x=0;x<q;x++)ze(b[x].name,R)&&P++;for(;P-- >0;){let x=u[c],k=F.exec(x)[2],j=k.toLowerCase()+R,T=l.getAttribute(j);l.removeAttribute(j);let v=T.split(Se);this.parts.push({type:"attribute",index:a,name:k,strings:v}),c+=v.length-1}}l.tagName==="TEMPLATE"&&(n.push(l),o.currentNode=l.content)}else if(l.nodeType===3){let b=l.data;if(b.indexOf(y)>=0){let q=l.parentNode,P=b.split(Se),x=P.length-1;for(let k=0;k<x;k++){let j,T=P[k];if(T==="")j=_();else{let v=F.exec(T);v!==null&&ze(v[2],R)&&(T=T.slice(0,v.index)+v[1]+v[2].slice(0,-R.length)+v[3]),j=document.createTextNode(T)}q.insertBefore(j,l),this.parts.push({type:"node",index:++a})}P[x]===""?(q.insertBefore(_(),l),s.push(l)):l.data=P[x],c+=x}}else if(l.nodeType===8)if(l.data===y){let b=l.parentNode;(l.previousSibling===null||a===i)&&(a++,b.insertBefore(_(),l)),i=a,this.parts.push({type:"node",index:a}),l.nextSibling===null?l.data="":(s.push(l),a--),c++}else{let b=-1;for(;(b=l.data.indexOf(y,b+1))!==-1;)this.parts.push({type:"node",index:-1}),c++}}for(let l of s)l.parentNode.removeChild(l)}},ze=(r,e)=>{let t=r.length-e.length;return t>=0&&r.slice(t)===e},I=r=>r.index!==-1,_=()=>document.createComment(""),F=/([ \x09\x0a\x0c\x0d])([^\0-\x1F\x7F-\x9F "'>=/]+)([ \x09\x0a\x0c\x0d]*=[ \x09\x0a\x0c\x0d]*(?:[^ \x09\x0a\x0c\x0d"'`<>=]*|"[^"]*|'[^']*))$/;var ee=133;function te(r,e){let{element:{content:t},parts:s}=r,n=document.createTreeWalker(t,ee,null,!1),o=O(s),i=s[o],a=-1,c=0,u=[],g=null;for(;n.nextNode();){a++;let l=n.currentNode;for(l.previousSibling===g&&(g=null),e.has(l)&&(u.push(l),g===null&&(g=l)),g!==null&&c++;i!==void 0&&i.index===a;)i.index=g!==null?-1:i.index-c,o=O(s,o),i=s[o]}u.forEach(l=>l.parentNode.removeChild(l))}var He=r=>{let e=r.nodeType===11?0:1,t=document.createTreeWalker(r,ee,null,!1);for(;t.nextNode();)e++;return e},O=(r,e=-1)=>{for(let t=e+1;t<r.length;t++){let s=r[t];if(I(s))return t}return-1};function Pe(r,e,t=null){let{element:{content:s},parts:n}=r;if(t==null){s.appendChild(e);return}let o=document.createTreeWalker(s,ee,null,!1),i=O(n),a=0,c=-1;for(;o.nextNode();)for(c++,o.currentNode===t&&(a=He(e),t.parentNode.insertBefore(e,t));i!==-1&&n[i].index===c;){if(a>0){for(;i!==-1;)n[i].index+=a,i=O(n,i);return}i=O(n,i)}}var Te=new WeakMap,se=r=>(...e)=>{let t=r(...e);return Te.set(t,!0),t},E=r=>typeof r=="function"&&Te.has(r);var f={},B={};var A=class{constructor(e,t,s){this.__parts=[],this.template=e,this.processor=t,this.options=s}update(e){let t=0;for(let s of this.__parts)s!==void 0&&s.setValue(e[t]),t++;for(let s of this.__parts)s!==void 0&&s.commit()}_clone(){let e=X?this.template.element.content.cloneNode(!0):document.importNode(this.template.element.content,!0),t=[],s=this.template.parts,n=document.createTreeWalker(e,133,null,!1),o=0,i=0,a,c=n.nextNode();for(;o<s.length;){if(a=s[o],!I(a)){this.__parts.push(void 0),o++;continue}for(;i<a.index;)i++,c.nodeName==="TEMPLATE"&&(t.push(c),n.currentNode=c.content),(c=n.nextNode())===null&&(n.currentNode=t.pop(),c=n.nextNode());if(a.type==="node"){let u=this.processor.handleTextExpression(this.options);u.insertAfterNode(c.previousSibling),this.__parts.push(u)}else this.__parts.push(...this.processor.handleAttributeExpressions(c,a.name,a.strings,this.options));o++}return X&&(document.adoptNode(e),customElements.upgrade(e)),e}};var Ce=window.trustedTypes&&trustedTypes.createPolicy("lit-html",{createHTML:r=>r}),De=` ${y} `,w=class{constructor(e,t,s,n){this.strings=e,this.values=t,this.type=s,this.processor=n}getHTML(){let e=this.strings.length-1,t="",s=!1;for(let n=0;n<e;n++){let o=this.strings[n],i=o.lastIndexOf("<!--");s=(i>-1||s)&&o.indexOf("-->",i+1)===-1;let a=F.exec(o);a===null?t+=o+(s?De:Z):t+=o.substr(0,a.index)+a[1]+a[2]+R+a[3]+y}return t+=this.strings[e],t}getTemplateElement(){let e=document.createElement("template"),t=this.getHTML();return Ce!==void 0&&(t=Ce.createHTML(t)),e.innerHTML=t,e}};var H=r=>r===null||!(typeof r=="object"||typeof r=="function"),W=r=>Array.isArray(r)||!!(r&&r[Symbol.iterator]),V=class{constructor(e,t,s){this.dirty=!0,this.element=e,this.name=t,this.strings=s,this.parts=[];for(let n=0;n<s.length-1;n++)this.parts[n]=this._createPart()}_createPart(){return new L(this)}_getValue(){let e=this.strings,t=e.length-1,s=this.parts;if(t===1&&e[0]===""&&e[1]===""){let o=s[0].value;if(typeof o=="symbol")return String(o);if(typeof o=="string"||!W(o))return o}let n="";for(let o=0;o<t;o++){n+=e[o];let i=s[o];if(i!==void 0){let a=i.value;if(H(a)||!W(a))n+=typeof a=="string"?a:String(a);else for(let c of a)n+=typeof c=="string"?c:String(c)}}return n+=e[t],n}commit(){this.dirty&&(this.dirty=!1,this.element.setAttribute(this.name,this._getValue()))}},L=class{constructor(e){this.value=void 0,this.committer=e}setValue(e){e!==f&&(!H(e)||e!==this.value)&&(this.value=e,E(e)||(this.committer.dirty=!0))}commit(){for(;E(this.value);){let e=this.value;this.value=f,e(this)}this.value!==f&&this.committer.commit()}},S=class{constructor(e){this.value=void 0,this.__pendingValue=void 0,this.options=e}appendInto(e){this.startNode=e.appendChild(_()),this.endNode=e.appendChild(_())}insertAfterNode(e){this.startNode=e,this.endNode=e.nextSibling}appendIntoPart(e){e.__insert(this.startNode=_()),e.__insert(this.endNode=_())}insertAfterPart(e){e.__insert(this.startNode=_()),this.endNode=e.endNode,e.endNode=this.startNode}setValue(e){this.__pendingValue=e}commit(){if(this.startNode.parentNode===null)return;for(;E(this.__pendingValue);){let t=this.__pendingValue;this.__pendingValue=f,t(this)}let e=this.__pendingValue;e!==f&&(H(e)?e!==this.value&&this.__commitText(e):e instanceof w?this.__commitTemplateResult(e):e instanceof Node?this.__commitNode(e):W(e)?this.__commitIterable(e):e===B?(this.value=B,this.clear()):this.__commitText(e))}__insert(e){this.endNode.parentNode.insertBefore(e,this.endNode)}__commitNode(e){this.value!==e&&(this.clear(),this.__insert(e),this.value=e)}__commitText(e){let t=this.startNode.nextSibling;e=e??"";let s=typeof e=="string"?e:String(e);t===this.endNode.previousSibling&&t.nodeType===3?t.data=s:this.__commitNode(document.createTextNode(s)),this.value=e}__commitTemplateResult(e){let t=this.options.templateFactory(e);if(this.value instanceof A&&this.value.template===t)this.value.update(e.values);else{let s=new A(t,e.processor,this.options),n=s._clone();s.update(e.values),this.__commitNode(n),this.value=s}}__commitIterable(e){Array.isArray(this.value)||(this.value=[],this.clear());let t=this.value,s=0,n;for(let o of e)n=t[s],n===void 0&&(n=new S(this.options),t.push(n),s===0?n.appendIntoPart(this):n.insertAfterPart(t[s-1])),n.setValue(o),n.commit(),s++;s<t.length&&(t.length=s,this.clear(n&&n.endNode))}clear(e=this.startNode){C(this.startNode.parentNode,e.nextSibling,this.endNode)}},D=class{constructor(e,t,s){if(this.value=void 0,this.__pendingValue=void 0,s.length!==2||s[0]!==""||s[1]!=="")throw new Error("Boolean attributes can only contain a single expression");this.element=e,this.name=t,this.strings=s}setValue(e){this.__pendingValue=e}commit(){for(;E(this.__pendingValue);){let t=this.__pendingValue;this.__pendingValue=f,t(this)}if(this.__pendingValue===f)return;let e=!!this.__pendingValue;this.value!==e&&(e?this.element.setAttribute(this.name,""):this.element.removeAttribute(this.name),this.value=e),this.__pendingValue=f}},J=class extends V{constructor(e,t,s){super(e,t,s);this.single=s.length===2&&s[0]===""&&s[1]===""}_createPart(){return new U(this)}_getValue(){return this.single?this.parts[0].value:super._getValue()}commit(){this.dirty&&(this.dirty=!1,this.element[this.name]=this._getValue())}},U=class extends L{},Ee=!1;(()=>{try{let r={get capture(){return Ee=!0,!1}};window.addEventListener("test",r,r),window.removeEventListener("test",r,r)}catch(r){}})();var G=class{constructor(e,t,s){this.value=void 0,this.__pendingValue=void 0,this.element=e,this.eventName=t,this.eventContext=s,this.__boundHandleEvent=n=>this.handleEvent(n)}setValue(e){this.__pendingValue=e}commit(){for(;E(this.__pendingValue);){let o=this.__pendingValue;this.__pendingValue=f,o(this)}if(this.__pendingValue===f)return;let e=this.__pendingValue,t=this.value,s=e==null||t!=null&&(e.capture!==t.capture||e.once!==t.once||e.passive!==t.passive),n=e!=null&&(t==null||s);s&&this.element.removeEventListener(this.eventName,this.__boundHandleEvent,this.__options),n&&(this.__options=Je(e),this.element.addEventListener(this.eventName,this.__boundHandleEvent,this.__options)),this.value=e,this.__pendingValue=f}handleEvent(e){typeof this.value=="function"?this.value.call(this.eventContext||this.element,e):this.value.handleEvent(e)}},Je=r=>r&&(Ee?{capture:r.capture,passive:r.passive,once:r.once}:r.capture);function re(r){let e=N.get(r.type);e===void 0&&(e={stringsArray:new WeakMap,keyString:new Map},N.set(r.type,e));let t=e.stringsArray.get(r.strings);if(t!==void 0)return t;let s=r.strings.join(y);return t=e.keyString.get(s),t===void 0&&(t=new M(r,r.getTemplateElement()),e.keyString.set(s,t)),e.stringsArray.set(r.strings,t),t}var N=new Map;var z=new WeakMap,ne=(r,e,t)=>{let s=z.get(e);s===void 0&&(C(e,e.firstChild),z.set(e,s=new S(Object.assign({templateFactory:re},t))),s.appendInto(e)),s.setValue(r),s.commit()};var oe=class{handleAttributeExpressions(e,t,s,n){let o=t[0];return o==="."?new J(e,t.slice(1),s).parts:o==="@"?[new G(e,t.slice(1),n.eventContext)]:o==="?"?[new D(e,t.slice(1),s)]:new V(e,t,s).parts}handleTextExpression(e){return new S(e)}},ie=new oe;typeof window!="undefined"&&(window.litHtmlVersions||(window.litHtmlVersions=[])).push("1.4.1");var p=(r,...e)=>new w(r,e,"html",ie);var Ne=(r,e)=>`${r}--${e}`,K=!0;typeof window.ShadyCSS=="undefined"?K=!1:typeof window.ShadyCSS.prepareTemplateDom=="undefined"&&(console.warn("Incompatible ShadyCSS version detected. Please update to at least @webcomponents/webcomponentsjs@2.0.2 and @webcomponents/shadycss@1.3.1."),K=!1);var Ke=r=>e=>{let t=Ne(e.type,r),s=N.get(t);s===void 0&&(s={stringsArray:new WeakMap,keyString:new Map},N.set(t,s));let n=s.stringsArray.get(e.strings);if(n!==void 0)return n;let o=e.strings.join(y);if(n=s.keyString.get(o),n===void 0){let i=e.getTemplateElement();K&&window.ShadyCSS.prepareTemplateDom(i,r),n=new M(e,i),s.keyString.set(o,n)}return s.stringsArray.set(e.strings,n),n},Qe=["html","svg"],Ye=r=>{Qe.forEach(e=>{let t=N.get(Ne(e,r));t!==void 0&&t.keyString.forEach(s=>{let{element:{content:n}}=s,o=new Set;Array.from(n.querySelectorAll("style")).forEach(i=>{o.add(i)}),te(s,o)})})},ke=new Set,Xe=(r,e,t)=>{ke.add(r);let s=t?t.element:document.createElement("template"),n=e.querySelectorAll("style"),{length:o}=n;if(o===0){window.ShadyCSS.prepareTemplateStyles(s,r);return}let i=document.createElement("style");for(let u=0;u<o;u++){let g=n[u];g.parentNode.removeChild(g),i.textContent+=g.textContent}Ye(r);let a=s.content;t?Pe(t,i,a.firstChild):a.insertBefore(i,a.firstChild),window.ShadyCSS.prepareTemplateStyles(s,r);let c=a.querySelector("style");if(window.ShadyCSS.nativeShadow&&c!==null)e.insertBefore(c.cloneNode(!0),e.firstChild);else if(t){a.insertBefore(i,a.firstChild);let u=new Set;u.add(i),te(t,u)}},je=(r,e,t)=>{if(!t||typeof t!="object"||!t.scopeName)throw new Error("The `scopeName` option is required.");let s=t.scopeName,n=z.has(e),o=K&&e.nodeType===11&&!!e.host,i=o&&!ke.has(s),a=i?document.createDocumentFragment():e;if(ne(r,a,Object.assign({templateFactory:Ke(s)},t)),i){let c=z.get(a);z.delete(a);let u=c.value instanceof A?c.value.template:void 0;Xe(s,a,u),C(e,e.firstChild),e.appendChild(a),z.set(e,c)}!n&&o&&window.ShadyCSS.styleElement(e.host)};var Re;window.JSCompiler_renameProperty=(r,e)=>r;var ae={toAttribute(r,e){switch(e){case Boolean:return r?"":null;case Object:case Array:return r==null?r:JSON.stringify(r)}return r},fromAttribute(r,e){switch(e){case Boolean:return r!==null;case Number:return r===null?null:Number(r);case Object:case Array:return JSON.parse(r)}return r}},Me=(r,e)=>e!==r&&(e===e||r===r),le={attribute:!0,type:String,converter:ae,reflect:!1,hasChanged:Me},ce=1,pe=1<<2,de=1<<3,he=1<<4,ue="finalized",$=class extends HTMLElement{constructor(){super();this.initialize()}static get observedAttributes(){this.finalize();let e=[];return this._classProperties.forEach((t,s)=>{let n=this._attributeNameForProperty(s,t);n!==void 0&&(this._attributeToPropertyMap.set(n,s),e.push(n))}),e}static _ensureClassProperties(){if(!this.hasOwnProperty(JSCompiler_renameProperty("_classProperties",this))){this._classProperties=new Map;let e=Object.getPrototypeOf(this)._classProperties;e!==void 0&&e.forEach((t,s)=>this._classProperties.set(s,t))}}static createProperty(e,t=le){if(this._ensureClassProperties(),this._classProperties.set(e,t),t.noAccessor||this.prototype.hasOwnProperty(e))return;let s=typeof e=="symbol"?Symbol():`__${e}`,n=this.getPropertyDescriptor(e,s,t);n!==void 0&&Object.defineProperty(this.prototype,e,n)}static getPropertyDescriptor(e,t,s){return{get(){return this[t]},set(n){let o=this[e];this[t]=n,this.requestUpdateInternal(e,o,s)},configurable:!0,enumerable:!0}}static getPropertyOptions(e){return this._classProperties&&this._classProperties.get(e)||le}static finalize(){let e=Object.getPrototypeOf(this);if(e.hasOwnProperty(ue)||e.finalize(),this[ue]=!0,this._ensureClassProperties(),this._attributeToPropertyMap=new Map,this.hasOwnProperty(JSCompiler_renameProperty("properties",this))){let t=this.properties,s=[...Object.getOwnPropertyNames(t),...typeof Object.getOwnPropertySymbols=="function"?Object.getOwnPropertySymbols(t):[]];for(let n of s)this.createProperty(n,t[n])}}static _attributeNameForProperty(e,t){let s=t.attribute;return s===!1?void 0:typeof s=="string"?s:typeof e=="string"?e.toLowerCase():void 0}static _valueHasChanged(e,t,s=Me){return s(e,t)}static _propertyValueFromAttribute(e,t){let s=t.type,n=t.converter||ae,o=typeof n=="function"?n:n.fromAttribute;return o?o(e,s):e}static _propertyValueToAttribute(e,t){if(t.reflect===void 0)return;let s=t.type,n=t.converter;return(n&&n.toAttribute||ae.toAttribute)(e,s)}initialize(){this._updateState=0,this._updatePromise=new Promise(e=>this._enableUpdatingResolver=e),this._changedProperties=new Map,this._saveInstanceProperties(),this.requestUpdateInternal()}_saveInstanceProperties(){this.constructor._classProperties.forEach((e,t)=>{if(this.hasOwnProperty(t)){let s=this[t];delete this[t],this._instanceProperties||(this._instanceProperties=new Map),this._instanceProperties.set(t,s)}})}_applyInstanceProperties(){this._instanceProperties.forEach((e,t)=>this[t]=e),this._instanceProperties=void 0}connectedCallback(){this.enableUpdating()}enableUpdating(){this._enableUpdatingResolver!==void 0&&(this._enableUpdatingResolver(),this._enableUpdatingResolver=void 0)}disconnectedCallback(){}attributeChangedCallback(e,t,s){t!==s&&this._attributeToProperty(e,s)}_propertyToAttribute(e,t,s=le){let n=this.constructor,o=n._attributeNameForProperty(e,s);if(o!==void 0){let i=n._propertyValueToAttribute(t,s);if(i===void 0)return;this._updateState=this._updateState|de,i==null?this.removeAttribute(o):this.setAttribute(o,i),this._updateState=this._updateState&~de}}_attributeToProperty(e,t){if(this._updateState&de)return;let s=this.constructor,n=s._attributeToPropertyMap.get(e);if(n!==void 0){let o=s.getPropertyOptions(n);this._updateState=this._updateState|he,this[n]=s._propertyValueFromAttribute(t,o),this._updateState=this._updateState&~he}}requestUpdateInternal(e,t,s){let n=!0;if(e!==void 0){let o=this.constructor;s=s||o.getPropertyOptions(e),o._valueHasChanged(this[e],t,s.hasChanged)?(this._changedProperties.has(e)||this._changedProperties.set(e,t),s.reflect===!0&&!(this._updateState&he)&&(this._reflectingProperties===void 0&&(this._reflectingProperties=new Map),this._reflectingProperties.set(e,s))):n=!1}!this._hasRequestedUpdate&&n&&(this._updatePromise=this._enqueueUpdate())}requestUpdate(e,t){return this.requestUpdateInternal(e,t),this.updateComplete}async _enqueueUpdate(){this._updateState=this._updateState|pe;try{await this._updatePromise}catch(t){}let e=this.performUpdate();return e!=null&&await e,!this._hasRequestedUpdate}get _hasRequestedUpdate(){return this._updateState&pe}get hasUpdated(){return this._updateState&ce}performUpdate(){if(!this._hasRequestedUpdate)return;this._instanceProperties&&this._applyInstanceProperties();let e=!1,t=this._changedProperties;try{e=this.shouldUpdate(t),e?this.update(t):this._markUpdated()}catch(s){throw e=!1,this._markUpdated(),s}e&&(this._updateState&ce||(this._updateState=this._updateState|ce,this.firstUpdated(t)),this.updated(t))}_markUpdated(){this._changedProperties=new Map,this._updateState=this._updateState&~pe}get updateComplete(){return this._getUpdateComplete()}_getUpdateComplete(){return this.getUpdateComplete()}getUpdateComplete(){return this._updatePromise}shouldUpdate(e){return!0}update(e){this._reflectingProperties!==void 0&&this._reflectingProperties.size>0&&(this._reflectingProperties.forEach((t,s)=>this._propertyToAttribute(s,this[s],t)),this._reflectingProperties=void 0),this._markUpdated()}updated(e){}firstUpdated(e){}};Re=ue;$[Re]=!0;var Le=Element.prototype,Yt=Le.msMatchesSelector||Le.webkitMatchesSelector;var Q=window.ShadowRoot&&(window.ShadyCSS===void 0||window.ShadyCSS.nativeShadow)&&"adoptedStyleSheets"in Document.prototype&&"replace"in CSSStyleSheet.prototype,me=Symbol(),Y=class{constructor(e,t){if(t!==me)throw new Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");this.cssText=e}get styleSheet(){return this._styleSheet===void 0&&(Q?(this._styleSheet=new CSSStyleSheet,this._styleSheet.replaceSync(this.cssText)):this._styleSheet=null),this._styleSheet}toString(){return this.cssText}},Ie=r=>new Y(String(r),me),Ze=r=>{if(r instanceof Y)return r.cssText;if(typeof r=="number")return r;throw new Error(`Value passed to 'css' function must be a 'css' function result: ${r}. Use 'unsafeCSS' to pass non-literal values, but
            take care to ensure page security.`)},d=(r,...e)=>{let t=e.reduce((s,n,o)=>s+Ze(n)+r[o+1],r[0]);return new Y(t,me)};(window.litElementVersions||(window.litElementVersions=[])).push("2.5.1");var Oe={},h=class extends ${static getStyles(){return this.styles}static _getUniqueStyles(){if(this.hasOwnProperty(JSCompiler_renameProperty("_styles",this)))return;let e=this.getStyles();if(Array.isArray(e)){let t=(o,i)=>o.reduceRight((a,c)=>Array.isArray(c)?t(c,a):(a.add(c),a),i),s=t(e,new Set),n=[];s.forEach(o=>n.unshift(o)),this._styles=n}else this._styles=e===void 0?[]:[e];this._styles=this._styles.map(t=>{if(t instanceof CSSStyleSheet&&!Q){let s=Array.prototype.slice.call(t.cssRules).reduce((n,o)=>n+o.cssText,"");return Ie(s)}return t})}initialize(){super.initialize(),this.constructor._getUniqueStyles(),this.renderRoot=this.createRenderRoot(),window.ShadowRoot&&this.renderRoot instanceof window.ShadowRoot&&this.adoptStyles()}createRenderRoot(){return this.attachShadow(this.constructor.shadowRootOptions)}adoptStyles(){let e=this.constructor._styles;e.length!==0&&(window.ShadyCSS!==void 0&&!window.ShadyCSS.nativeShadow?window.ShadyCSS.ScopingShim.prepareAdoptedCssText(e.map(t=>t.cssText),this.localName):Q?this.renderRoot.adoptedStyleSheets=e.map(t=>t instanceof CSSStyleSheet?t:t.styleSheet):this._needsShimAdoptedStyleSheets=!0)}connectedCallback(){super.connectedCallback(),this.hasUpdated&&window.ShadyCSS!==void 0&&window.ShadyCSS.styleElement(this)}update(e){let t=this.render();super.update(e),t!==Oe&&this.constructor.render(t,this.renderRoot,{scopeName:this.localName,eventContext:this}),this._needsShimAdoptedStyleSheets&&(this._needsShimAdoptedStyleSheets=!1,this.constructor._styles.forEach(s=>{let n=document.createElement("style");n.textContent=s.cssText,this.renderRoot.appendChild(n)}))}render(){return Oe}};h.finalized=!0;h.render=je;h.shadowRootOptions={mode:"open"};var Ve=class extends h{static get styles(){return d`
      :host {
        display: block;
        padding: 25px;
        color: var(--puzzle-shell-text-color, #000);
      }
    `}static get properties(){return{title:{type:String},counter:{type:Number}}}constructor(){super();this.title="Hey there",this.counter=5}render(){return p`
      <h2>${this.title} Nr. ${this.counter}!</h2>
      <button @click=${this.__increment}>increment</button>
    `}};var Ue=d`
  /* Base colors */
  --pzsh-color-white: #ffffff;
  --pzsh-color-gray-1: #fafafa;
  --pzsh-color-gray-2: #f2f2f2;
  --pzsh-color-gray-3: #d8d8d8;
  --pzsh-color-gray-4: #62676b;

  /* Puzzle brand colors */
  --pzsh-color-brand-1: #1e5a96;
  --pzsh-color-brand-2: #3b7bbe;
  --pzsh-color-brand-3: #238bca;
  --pzsh-color-brand-4: #3fa8e0;
  --pzsh-color-brand-5: #46bcc0;
  --pzsh-color-brand-6: #2c97a6;
  --pzsh-color-brand-7: #69b978;
  --pzsh-color-brand-8: #61b44b;

  --pzsh-color-brand-alt-1: #dcedf9;
  --pzsh-color-brand-alt-2: #1c2948;
  --pzsh-color-brand-alt-3: #3fa8e0; /* Logo color */
  --pzsh-color-brand-alt-4: #69b978; /* Logo color */

  /* Component colors */
  --pzsh-topbar-bg: var(--pzsh-color-brand-1);
  --pzsh-topbar-bg-alt: var(--pzsh-color-brand-2);
  --pzsh-topbar-fg: var(--pzsh-color-white);
  --pzsh-topbar-menu-bg: var(--pzsh-color-brand-3);
  --pzsh-topbar-menu-bg-alt: var(--pzsh-color-brand-4);
  --pzsh-topbar-menu-fg: var(--pzsh-color-white);
  --pzsh-banner-bg: var(--pzsh-color-brand-alt-1);
  --pzsh-hero-bg-start: var(--pzsh-banner-bg);
  --pzsh-hero-bg-end: var(--pzsh-color-white);
  --pzsh-footer-bg: var(--pzsh-color-gray-2);
  --pzsh-footer-border: var(--pzsh-color-gray-3);

  /* Fonts */
  --pzsh-font-family: "Roboto", sans-serif;
  --pzsh-monospace-font-family: "Roboto Mono", monospace;

  /* Spacings */
  --pzsh-spacer: 8px;

  /* Sizes */
  --logo-height: 32px;
  --pzsh-topbar-height: calc(2 * var(--pzsh-spacer) + var(--logo-height));
  --pzsh-banner-small-height: calc(8 * var(--pzsh-spacer));
  --pzsh-banner-large-height: calc(12 * var(--pzsh-spacer));
  --pzsh-hero-height: calc(20 * var(--pzsh-spacer));
`,$e=d`
  @import url("https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,500;1,400;1,500&family=Roboto+Mono:wght@400;500&display=swap");
`,m=d`
  :host {
    ${Ue}
  }
  ${$e}

  /* Reset */
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  img,
  svg {
    display: block;
  }
`;function et(r){let e=document.createElement("style");e.innerText=r,document.querySelector("body").appendChild(e)}et(d`
  :root {
    ${Ue}
  }
  ${$e}
`);var fe=class extends h{static get styles(){return[m,d`
        .banner {
          height: var(--pzsh-banner-small-height);
          display: flex;
          background: var(--pzsh-banner-bg);
        }
        /* TODO: large version for welcome pages */
        /* height: var(--pzsh-banner-large-height); */

        /* dummy content */
        .search {
          margin: auto;
        }
        .search input {
          font-size: 16px;
          padding: 0.5em;
          border: 1px solid var(--pzsh-color-gray-3);
        }
        .search input::placeholder {
          color: var(--pzsh-color-gray-4);
        }
      `]}render(){return p`<div class="banner">
      <!-- dummy content -->
      <div class="search"><input placeholder="Search..." type="text" /></div>
    </div>`}};window.customElements.define("pzsh-banner",fe);var ge=class extends h{static get styles(){return[m,d`
        .container {
          display: flex;
          flex-direction: column;
          min-height: 100vh;
        }
        ::slotted(*) {
          /* Let the content eat the rest */
          flex: auto;
        }
        ::slotted(pzsh-topbar),
        ::slotted(pzsh-banner),
        ::slotted(pzsh-hero),
        ::slotted(pzsh-footer) {
          flex: none;
        }
      `]}render(){return p`<div class="container">
      <slot></slot>
    </div>`}};window.customElements.define("pzsh-container",ge);var ye=class extends h{static get styles(){return[m,d`
        :host(pzsh-footer) {
          padding: calc(var(--pzsh-spacer)) calc(6 * var(--pzsh-spacer));
          background-color: var(--pzsh-footer-bg);

          display: flex;
          justify-content: space-between;
          align-items: center;

          border-top: 2px solid var(--pzsh-footer-border);
        }

        ::slotted(*) {
          color: var(--pzsh-color-gray-4);
          font-family: Roboto, sans-serif;
          gap: calc(2 * var(--pzsh-spacer));

          padding-top: var(--pzsh-spacer);
          padding-bottom: var(--pzsh-spacer);

          display: flex;
          flex: 1;
        }

        ::slotted([slot="start"]) {
          align-items: center;
          justify-content: flex-start;
        }

        ::slotted([slot="center"]) {
          align-items: center;
          justify-content: center;
        }

        ::slotted([slot="end"]) {
          align-items: center;
          justify-content: flex-end;
        }

        @media (max-width: 800px) {
          :host(pzsh-footer) {
            padding: calc(var(--pzsh-spacer)) calc(3 * var(--pzsh-spacer));

            display: flex;
            flex-direction: column;

            row-gap: var(--pzsh-spacer);
          }

          ::slotted([slot="start"]) {
            order: 2;
          }

          ::slotted([slot="center"]) {
            order: 1;
          }

          ::slotted([slot="end"]) {
            order: 3;
          }
        }
      `]}render(){return p`
      <slot name="start"></slot>
      <slot name="center"></slot>
      <slot name="end"></slot>
      <slot></slot>
    `}};window.customElements.define("pzsh-footer",ye);var be=class extends h{static get styles(){return[m,d`
        :host {
          height: var(--pzsh-hero-height);
          display: grid;
          grid-template-columns:
            1fr min-content calc(4 * var(--pzsh-spacer))
            max-content 1fr;
          grid-template-rows: 1fr max-content 1fr;
          background: var(--pzsh-hero-bg-start);
          background: linear-gradient(
            180deg,
            var(--pzsh-hero-bg-start) 0%,
            var(--pzsh-hero-bg-end) 100%
          );
        }

        ::slotted([slot="title"]),
        ::slotted([slot="slogan"]) {
          font-family: var(--pzsh-font-family);
          font-weight: normal;
          line-height: 1;
        }

        ::slotted([slot="title"]) {
          margin: 0;
          font-size: 32px;
          white-space: nowrap;
          color: var(--pzsh-color-brand-alt-2);
        }
        ::slotted([slot="slogan"]) {
          margin-top: var(--pzsh-spacer);
          font-size: 18px;
          color: var(--pzsh-color-brand-alt-3);
        }

        .text {
          grid-column: 2/3;
          grid-row: 2/3;
        }
        ::slotted([slot="logo"]) {
          grid-column: 4/5;
          grid-row: 2/3;
        }
      `]}render(){return p`
      <div class="text">
        <slot name="title"></slot>
        <slot name="slogan"></slot>
      </div>
      <slot name="logo"></slot>
    `}};window.customElements.define("pzsh-hero",be);var tt={bars:p`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M3 8h18a1 1 0 000-2H3a1 1 0 000 2zm18 8H3a1 1 0 000 2h18a1 1 0 000-2zm0-5H3a1 1 0 000 2h18a1 1 0 000-2z"/></svg>`,github:p`<svg xmlns="http://www.w3.org/2000/svg" data-name="Layer 1" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2.247a10 10 0 00-3.162 19.487c.5.088.687-.212.687-.475 0-.237-.012-1.025-.012-1.862-2.513.462-3.163-.613-3.363-1.175a3.636 3.636 0 00-1.025-1.413c-.35-.187-.85-.65-.013-.662a2.001 2.001 0 011.538 1.025 2.137 2.137 0 002.912.825 2.104 2.104 0 01.638-1.338c-2.225-.25-4.55-1.112-4.55-4.937a3.892 3.892 0 011.025-2.688 3.594 3.594 0 01.1-2.65s.837-.262 2.75 1.025a9.427 9.427 0 015 0c1.912-1.3 2.75-1.025 2.75-1.025a3.593 3.593 0 01.1 2.65 3.869 3.869 0 011.025 2.688c0 3.837-2.338 4.687-4.563 4.937a2.368 2.368 0 01.675 1.85c0 1.338-.012 2.413-.012 2.75 0 .263.187.575.687.475A10.005 10.005 0 0012 2.247z"/></svg>`,multiply:p`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M13.41 12l6.3-6.29a1 1 0 10-1.42-1.42L12 10.59l-6.29-6.3a1 1 0 00-1.42 1.42l6.3 6.29-6.3 6.29a1 1 0 000 1.42 1 1 0 001.42 0l6.29-6.3 6.29 6.3a1 1 0 001.42 0 1 1 0 000-1.42z"/></svg>`,"question-circle":p`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M11.29 15.29a1.58 1.58 0 00-.12.15.76.76 0 00-.09.18.64.64 0 00-.06.18 1.36 1.36 0 000 .2.84.84 0 00.08.38.9.9 0 00.54.54.94.94 0 00.76 0 .9.9 0 00.54-.54A1 1 0 0013 16a1 1 0 00-.29-.71 1 1 0 00-1.42 0zM12 2a10 10 0 1010 10A10 10 0 0012 2zm0 18a8 8 0 118-8 8 8 0 01-8 8zm0-13a3 3 0 00-2.6 1.5 1 1 0 101.73 1A1 1 0 0112 9a1 1 0 010 2 1 1 0 00-1 1v1a1 1 0 002 0v-.18A3 3 0 0012 7z"/></svg>`,"user-circle":p`<svg xmlns="http://www.w3.org/2000/svg" data-name="Layer 1" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2a10 10 0 00-7.35 16.76 10 10 0 0014.7 0A10 10 0 0012 2zm0 18a8 8 0 01-5.55-2.25 6 6 0 0111.1 0A8 8 0 0112 20zm-2-10a2 2 0 112 2 2 2 0 01-2-2zm8.91 6A8 8 0 0015 12.62a4 4 0 10-6 0A8 8 0 005.09 16 7.92 7.92 0 014 12a8 8 0 0116 0 7.92 7.92 0 01-1.09 4z"/></svg>`,"users-alt":p`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M12.3 12.22A4.92 4.92 0 0014 8.5a5 5 0 00-10 0 4.92 4.92 0 001.7 3.72A8 8 0 001 19.5a1 1 0 002 0 6 6 0 0112 0 1 1 0 002 0 8 8 0 00-4.7-7.28zM9 11.5a3 3 0 113-3 3 3 0 01-3 3zm9.74.32A5 5 0 0015 3.5a1 1 0 000 2 3 3 0 013 3 3 3 0 01-1.5 2.59 1 1 0 00-.5.84 1 1 0 00.45.86l.39.26.13.07a7 7 0 014 6.38 1 1 0 002 0 9 9 0 00-4.23-7.68z"/></svg>`},xe=class extends h{static get styles(){return[m,d`
        :host {
          display: inline-block;
        }
        svg {
          width: 24px;
          height: 24px;
        }
      `]}static get properties(){return{name:{type:String}}}render(){return p`${tt[this.name]}`}};window.customElements.define("pzsh-icon",xe);var qe=class{constructor(e){this.classes=new Set,this.changed=!1,this.element=e;let t=(e.getAttribute("class")||"").split(/\s+/);for(let s of t)this.classes.add(s)}add(e){this.classes.add(e),this.changed=!0}remove(e){this.classes.delete(e),this.changed=!0}commit(){if(this.changed){let e="";this.classes.forEach(t=>e+=t+" "),this.element.setAttribute("class",e)}}},Fe=new WeakMap,Be=se(r=>e=>{if(!(e instanceof L)||e instanceof U||e.committer.name!=="class"||e.committer.parts.length>1)throw new Error("The `classMap` directive must be used in the `class` attribute and must be the only part in the attribute.");let{committer:t}=e,{element:s}=t,n=Fe.get(e);n===void 0&&(s.setAttribute("class",t.strings.join(" ")),Fe.set(e,n=new Set));let o=s.classList||new qe(s);n.forEach(i=>{i in r||(o.remove(i),n.delete(i))});for(let i in r){let a=r[i];a!=n.has(i)&&(a?(o.add(i),n.add(i)):(o.remove(i),n.delete(i)))}typeof o.commit=="function"&&o.commit()});var _e=class extends h{static get styles(){return[m,d`
        .topbar {
          height: var(--pzsh-topbar-height);
          padding: calc(var(--pzsh-spacer)) calc(6 * var(--pzsh-spacer));
          display: flex;
          align-items: center;
          background: var(--pzsh-topbar-bg);
        }

        a.logo-link {
          display: flex; /* Fix vertical centering */
        }

        .menu {
          flex: auto;
        }

        .menu-button {
          display: none;
          padding: var(--pzsh-spacer);
          border: 0;
          border-radius: 3px;
          background-color: transparent;
          color: var(--pzsh-topbar-fg);
          cursor: pointer;
        }
        .menu-button:hover {
          background-color: var(--pzsh-topbar-bg-alt);
        }
        .menu-button pzsh-icon {
          display: block;
        }

        ::slotted([slot="actions"]) {
          display: flex;
          justify-content: flex-end;
        }

        @media (max-width: 800px) {
          .topbar {
            padding-left: calc(2 * var(--pzsh-spacer));
            padding-right: calc(2 * var(--pzsh-spacer));
          }

          .menu-button {
            display: block;
            margin-left: auto;
          }
          .menu:not(.open) {
            display: none;
          }
          .menu {
            padding: var(--pzsh-spacer) 0;
            position: absolute;
            top: var(--pzsh-topbar-height);
            left: 0;
            right: 0;
            z-index: 1000;
            background-color: var(--pzsh-topbar-menu-bg);
          }

          ::slotted([slot="actions"]) {
            flex-direction: column;
          }
        }
      `]}static get properties(){return{hasMenuItems:{attribute:!1},menuOpen:{attribute:!1},href:{type:String}}}constructor(){super();this.hasMenuItems=!1,this.menuOpen=!1,this.menuItemsObserver=new MutationObserver(e=>e.forEach(this.__updateHasMenuItems.bind(this))),this.shadowRoot.addEventListener("slotchange",this.__handleActionsSlotAssignment.bind(this))}firstUpdated(){this.__updateHasMenuItems()}__handleActionsSlotAssignment(e){let t=e.target;t.getAttribute("name")==="actions"&&t.assignedNodes().forEach(s=>this.menuItemsObserver.observe(s,{childList:!0}))}__updateHasMenuItems(){let e=this.shadowRoot.querySelector('slot[name="actions"]');this.hasMenuItems=e.assignedNodes().some(t=>t.children.length>0)}__toggleMenu(){this.menuOpen=!this.menuOpen}__renderMenuButton(){if(this.hasMenuItems){let e=this.menuOpen?"multiply":"bars";return p`<button class="menu-button" @click=${this.__toggleMenu}>
        <pzsh-icon name=${e}></pzsh-icon>
      </button>`}return null}__renderLogo(){return this.href?p`<a class="logo-link" href=${this.href}>
          <slot name="logo"></slot>
        </a>`:p`<slot name="logo"></slot>`}render(){let e={menu:!0,open:this.menuOpen};return p`<div class="topbar">
      ${this.__renderLogo()}
      <div class=${Be(e)}>
        <slot name="actions"></slot>
      </div>
      ${this.__renderMenuButton()}
    </div>`}};window.customElements.define("pzsh-topbar",_e);var ve=class extends h{static get styles(){return[m,d`
        a {
          display: flex;
          align-items: center;
          margin-left: calc(3 * var(--pzsh-spacer));
          font-family: var(--pzsh-font-family);
          color: var(--pzsh-topbar-fg);
          text-decoration: none;
        }
        a:hover,
        a:active {
          text-decoration: underline;
        }
        ::slotted(pzsh-icon),
        ::slotted(svg) {
          margin-right: calc(var(--pzsh-spacer) / 2);
        }

        @media (max-width: 800px) {
          a {
            margin-left: 0;
            padding: calc(2 * var(--pzsh-spacer)) calc(3 * var(--pzsh-spacer));
            color: var(--pzsh-topbar-menu-fg);
          }
          a:hover,
          a:active {
            background-color: var(--pzsh-topbar-menu-bg-alt);
            text-decoration: none;
          }
        }
      `]}static get properties(){return{href:{type:String}}}constructor(){super();this.href="#"}dispatchClick(e){this.dispatchEvent(e)}render(){return p`<a href="${this.href}" @click=${this.dispatchClick}>
      <slot></slot>
    </a>`}};window.customElements.define("pzsh-topbar-link",ve);var we=class extends h{static get styles(){return[m,d`
        a {
          display: flex;
          align-items: center;
          font-family: var(--pzsh-font-family);
          color: var(--pzsh-color-brand-1);
          text-decoration: none;
        }
        a:hover,
        a:active {
          text-decoration: underline;
        }
        ::slotted(pzsh-icon),
        ::slotted(svg) {
          margin-right: calc(var(--pzsh-spacer) / 2);
        }

        @media (max-width: 800px) {
          a {
            margin-left: 0;
            color: var(--pzsh-color-brand-1);
          }
          a:hover,
          a:active {
            background-color: var(--pzsh-topbar-menu-bg-alt);
            text-decoration: none;
          }
        }
      `]}static get properties(){return{href:{type:String}}}constructor(){super();this.href="#"}dispatchClick(e){this.dispatchEvent(e)}render(){return p`<a href="${this.href}" @click=${this.dispatchClick}>
      <slot></slot>
    </a>`}};window.customElements.define("pzsh-footer-link",we);})();
/**
 * @license
 * Copyright (c) 2017 The Polymer Project Authors. All rights reserved.
 * This code may only be used under the BSD style license found at
 * http://polymer.github.io/LICENSE.txt
 * The complete set of authors may be found at
 * http://polymer.github.io/AUTHORS.txt
 * The complete set of contributors may be found at
 * http://polymer.github.io/CONTRIBUTORS.txt
 * Code distributed by Google as part of the polymer project is also
 * subject to an additional IP rights grant found at
 * http://polymer.github.io/PATENTS.txt
 */
/**
 * @license
 * Copyright (c) 2018 The Polymer Project Authors. All rights reserved.
 * This code may only be used under the BSD style license found at
 * http://polymer.github.io/LICENSE.txt
 * The complete set of authors may be found at
 * http://polymer.github.io/AUTHORS.txt
 * The complete set of contributors may be found at
 * http://polymer.github.io/CONTRIBUTORS.txt
 * Code distributed by Google as part of the polymer project is also
 * subject to an additional IP rights grant found at
 * http://polymer.github.io/PATENTS.txt
 */
/**
@license
Copyright (c) 2019 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at
http://polymer.github.io/LICENSE.txt The complete set of authors may be found at
http://polymer.github.io/AUTHORS.txt The complete set of contributors may be
found at http://polymer.github.io/CONTRIBUTORS.txt Code distributed by Google as
part of the polymer project is also subject to an additional IP rights grant
found at http://polymer.github.io/PATENTS.txt
*/
//# sourceMappingURL=pzsh-bundle.js.map
