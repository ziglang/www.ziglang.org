---
title: Communities
menu_title: "Communities"
mobile_menu_title: "Communities"
toc: false
---
<style>
 h1, h2, h3 {
    /*font-size: 2rem;*/
 }

 .communities {
   display: grid;
   grid-template-columns: repeat(2, 1fr);
   gap: 10px;
   flex-wrap: wrap;
   justify-content: space-between;
   margin-top: 1rem;
 }
 @media only screen and (max-width: 1000px) {
   .communities {
     grid-template-columns: repeat(1, 1fr);
   }
   .community {
     margin-left: -1rem;
     margin-right: -1rem;
     border-radius: 0 !important;
   }
 }

 .community {
   display: flex;
   flex-direction: column;
   border-radius: 1rem;
   background-color: #333;
 }
 .community p {
   margin: 0;
 }
 .community-header, .community-references {
   padding: .5rem;
   padding-left: 1rem;
 }


 .community-header {
   display: flex;
   flex-direction: row;
   align-items: center;
 }
 .community-header > span.title {
   font-size: 2em;
 }
 .community-header > div > h2 {
   margin-top: 0;
   margin-bottom: -.25rem;
   word-wrap: anywhere;
 }
 .community svg {
   color: #f7a41d;
   flex-shrink: 0;
 }
 .community-header > svg {
   width: 2.5rem !important;
   height: 2.5rem !important;
   margin-right: 0.75rem;
 }
 .community-header > div > .language {
  color: #f7a41d;
 }
 .community-header > div > .owner {
   display: inline-block;
   margin-top: .25rem;
 }

 .community-place-description {
   border-left: 2px solid #f7a41d;
   background-color: #444;
   padding: 0.5rem;
   padding-top: 0.25rem;
   padding-bottom: 0.25rem;
   height: 5.25rem;
   overflow: auto;
   margin-right: 0.5rem;
   margin-left: 0.5rem;
   margin-bottom: 0.5rem;
   font-size: 14px;
 }

 .community-place-extra {
   padding: 5px 15px;
 }
 .community-place-extra, .community-references {
   text-align: center;
 }
 .community-place-extra .merchanidise-supports-zsf {
   display: flex;
   align-items: center;
   justify-content: center;
   font-size: small;
   font-weight: bold;
   color: white;
 }
 .community-place-extra .merchanidise-supports-zsf > svg {
   margin-right: .25rem;
 }

 #showing {
   margin-bottom: 1rem;
 }
 .communities .community { display: none; }
 input[value="all"]:checked ~ .communities .community-irc,
 input[value="irc"]:checked ~ .communities .community-irc { display: flex; }

 input[value="all"]:checked ~ .communities .community-discord,
 input[value="discord"]:checked ~ .communities .community-discord { display: flex; }

 input[value="all"]:checked ~ .communities .community-telegram,
 input[value="telegram"]:checked ~ .communities .community-telegram { display: flex; }

 input[value="all"]:checked ~ .communities .community-matrix,
 input[value="matrix"]:checked ~ .communities .community-matrix { display: flex; }

 input[value="all"]:checked ~ .communities .community-email_list,
 input[value="email_list"]:checked ~ .communities .community-email_list { display: flex; }

 input[value="all"]:checked ~ .communities .community-reddit,
 input[value="reddit"]:checked ~ .communities .community-reddit { display: flex; }

 input[value="all"]:checked ~ .communities .community-forum,
 input[value="forum"]:checked ~ .communities .community-forum { display: flex; }

 input[value="all"]:checked ~ .communities .community-newsletter,
 input[value="newsletter"]:checked ~ .communities .community-newsletter { display: flex; }

 input[value="all"]:checked ~ .communities .community-merchandise,
 input[value="merchandise"]:checked ~ .communities .community-merchandise { display: flex; }

 input[value="all"]:checked ~ .communities .community-multimedia,
 input[value="multimedia"]:checked ~ .communities .community-multimedia { display: flex; }

 input[value="all"]:checked ~ .communities .community-learning,
 input[value="learning"]:checked ~ .communities .community-learning { display: flex; }

 input[value="all"]:checked ~ .communities .community-miscellaneous,
 input[value="miscellaneous"]:checked ~ .communities .community-miscellaneous { display: flex; }
</style>

# The Zig community is decentralized
Anyone is free to start and maintain their own space for the community to gather.
There is no concept of “official” or “unofficial”, however, each gathering place has its own moderators and rules. 

<form>
  <input type=radio name="showing" id="radio-all" value="all" checked><label for="radio-all">All</label>
  <input type=radio name="showing" id="radio-irc" value="irc"><label for="radio-irc">IRC</label>
  <input type=radio name="showing" id="radio-discord" value="discord"><label for="radio-discord">Discord</label>
  <input type=radio name="showing" id="radio-telegram" value="telegram"><label for="radio-telegram">Telegram</label>
  <input type=radio name="showing" id="radio-matrix" value="matrix"><label for="radio-matrix">Matrix</label>
  <input type=radio name="showing" id="radio-email_list" value="email_list"><label for="radio-email_list">Mailing lists</label>
  <input type=radio name="showing" id="radio-reddit" value="reddit"><label for="radio-reddit">Reddit</label>
  <input type=radio name="showing" id="radio-forum" value="forum"><label for="radio-forum">Forums</label>
  <input type=radio name="showing" id="radio-newsletter" value="newsletter"><label for="radio-newsletter">Newsletters</label>
  <input type=radio name="showing" id="radio-merchandise" value="merchandise"><label for="radio-merchandise">Merchandise</label>
  <br/>
  <input type=radio name="showing" id="radio-multimedia" value="multimedia"><label for="radio-multimedia">Multimedia</label>
  <input type=radio name="showing" id="radio-learning" value="learning"><label for="radio-learning">Learning</label>
  <input type=radio name="showing" id="radio-miscellaneous" value="miscellaneous"><label for="radio-miscellaneous">Miscellaneous</label>

  <div class="communities">
    {{< communities/places "irc" >}}
    {{< communities/places "discord" >}}
    {{< communities/places "telegram" >}}
    {{< communities/places "matrix" >}}
    {{< communities/places "email_list" >}}
    {{< communities/places "reddit" >}}
    {{< communities/places "forum" >}}
    {{< communities/places "newsletter" >}}
    {{< communities/places "merchandise" >}}
    {{< communities/places "multimedia" >}}
    {{< communities/places "learning" >}}
    {{< communities/places "miscellaneous" >}}
  </div>
</form>

## Adding your community
If you started a new Zig community, you can add it to the list above by [sending us a PR on GitHub](https://github.com/ziglang/www.ziglang.org).
