---
title: Communities
menu_title: "Communities"
mobile_menu_title: "Communities"
toc: false
---
<style>
  .community {
    display: flex;
    flex-direction: column;
  }
  .community>.name>h3 {
    margin: 0;
    padding-left: 0.5rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid #f7a41d;
  }
  .community>.description {
    flex: 1;
    padding-left: 0.5rem;
    font-size: 14px;
    line-height: 1.25;
    background-color: #333;
    padding: 1rem;
  }
  .community>.people {
    background-color: #333;
    padding: 0.5rem;
    font-size: 14px;
  }
  .communities {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1em;
    flex-wrap: wrap;
    justify-content: space-between;
    margin-top: 1rem;
    margin-bottom: 2rem;
  }

  .category>h2 {
    display: flex;
    align-items: center;
    margin-top: 0;
    padding-top: 1rem;
  }
  .category>h2>svg {
    width: 2em !important;
    height: 2em !important;
  }
  .category.right {
    border-bottom: 1px solid #f7a41d;
    border-right: 1px solid #f7a41d;
    padding-right: 1rem;
  }
  .category.left {
    border-bottom: 1px solid #f7a41d;
    border-left: 1px solid #f7a41d;
    padding-left: 1rem;
  }
  .category:last-of-type {
    border-bottom: none;
    padding-bottom: 2rem;
  }
  .category.left>h2>svg {
    margin-right: 0.5rem;
  }
  .category.right>h2 {
    flex-flow: row-reverse;
  }
  .category.right>h2>svg {
    margin-left: 0.5rem;
    float: right;
  }
  .category.right>.communities {
    direction: rtl;
  }
  .category.right>.communities>* {
    direction: ltr;
  }
</style>

# The Zig community is decentralized
Anyone is free to start and maintain their own space for the community to gather: there is no concept of “official” or “unofficial”. Each gathering place has its own moderators and rules.

TODO(slimsag)
- [The Zig community is decentralized](#the-zig-community-is-decentralized)
  - [Adding your community](#adding-your-community)

<div class="category left">
  <h2>
    <!-- https://materialdesignicons.com/icon/book-open-page-variant -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Learning</title>
        <path fill="currentColor" d="M19 2L14 6.5V17.5L19 13V2M6.5 5C4.55 5 2.45 5.4 1 6.5V21.16C1 21.41 1.25 21.66 1.5 21.66C1.6 21.66 1.65 21.59 1.75 21.59C3.1 20.94 5.05 20.5 6.5 20.5C8.45 20.5 10.55 20.9 12 22C13.35 21.15 15.8 20.5 17.5 20.5C19.15 20.5 20.85 20.81 22.25 21.56C22.35 21.61 22.4 21.59 22.5 21.59C22.75 21.59 23 21.34 23 21.09V6.5C22.4 6.05 21.75 5.75 21 5.5V19C19.9 18.65 18.7 18.5 17.5 18.5C15.8 18.5 13.35 19.15 12 20V6.5C10.55 5.4 8.45 5 6.5 5Z" />
    </svg>
    Learning
  </h2>
  <div class="communities">
    {{< communities/places "learning" >}}
  </div>
</div>

<div class="category right">
  <h2>
    <!-- https://materialdesignicons.com/icon/help-circle -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <path fill="currentColor" d="M15.07,11.25L14.17,12.17C13.45,12.89 13,13.5 13,15H11V14.5C11,13.39 11.45,12.39 12.17,11.67L13.41,10.41C13.78,10.05 14,9.55 14,9C14,7.89 13.1,7 12,7A2,2 0 0,0 10,9H8A4,4 0 0,1 12,5A4,4 0 0,1 16,9C16,9.88 15.64,10.67 15.07,11.25M13,19H11V17H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12C22,6.47 17.5,2 12,2Z" />
    </svg>
    Ask questions
  </h2>
  <div class="communities">
    {{< communities/places "help" >}}
  </div>
</div>

<div class="category left">
  <h2>
    <!-- https://materialdesignicons.com/icon/newspaper-variant-outline -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Newsletter</title>
        <path fill="currentColor" d="M20 5L20 19L4 19L4 5H20M20 3H4C2.89 3 2 3.89 2 5V19C2 20.11 2.89 21 4 21H20C21.11 21 22 20.11 22 19V5C22 3.89 21.11 3 20 3M18 15H6V17H18V15M10 7H6V13H10V7M12 9H18V7H12V9M18 11H12V13H18V11Z" />
    </svg>
    News
  </h2>
  <div class="communities">
    {{< communities/places "news" >}}
  </div>
</div>

<div class="category right">
  <h2>
    <!-- https://materialdesignicons.com/icon/forum -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Forum</title>
        <path fill="currentColor" d="M17,12V3A1,1 0 0,0 16,2H3A1,1 0 0,0 2,3V17L6,13H16A1,1 0 0,0 17,12M21,6H19V15H6V17A1,1 0 0,0 7,18H18L22,22V7A1,1 0 0,0 21,6Z" />
    </svg>
    Forums & mailing lists
  </h2>
  <div class="communities">
    {{< communities/places "forums" >}}
  </div>
</div>

<div class="category left">
  <h2>
    <!-- TODO -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Forum</title>
        <path fill="currentColor" d="M17,12V3A1,1 0 0,0 16,2H3A1,1 0 0,0 2,3V17L6,13H16A1,1 0 0,0 17,12M21,6H19V15H6V17A1,1 0 0,0 7,18H18L22,22V7A1,1 0 0,0 21,6Z" />
    </svg>
    Multimedia
  </h2>
  <div class="communities">
    {{< communities/places "multimedia" >}}
  </div>
</div>

<div class="category right">
  <h2>
    <!-- TODO -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Forum</title>
        <path fill="currentColor" d="M17,12V3A1,1 0 0,0 16,2H3A1,1 0 0,0 2,3V17L6,13H16A1,1 0 0,0 17,12M21,6H19V15H6V17A1,1 0 0,0 7,18H18L22,22V7A1,1 0 0,0 21,6Z" />
    </svg>
    Chat
  </h2>
  <div class="communities">
    {{< communities/places "chat" >}}
  </div>
</div>

<div class="category left">
  <h2>
    <!-- TODO -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Forum</title>
        <path fill="currentColor" d="M17,12V3A1,1 0 0,0 16,2H3A1,1 0 0,0 2,3V17L6,13H16A1,1 0 0,0 17,12M21,6H19V15H6V17A1,1 0 0,0 7,18H18L22,22V7A1,1 0 0,0 21,6Z" />
    </svg>
    Localized
  </h2>
  <div class="communities">
    {{< communities/places "localized" >}}
  </div>
</div>

<div class="category right">
  <h2>
    <!-- TODO -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Forum</title>
        <path fill="currentColor" d="M17,12V3A1,1 0 0,0 16,2H3A1,1 0 0,0 2,3V17L6,13H16A1,1 0 0,0 17,12M21,6H19V15H6V17A1,1 0 0,0 7,18H18L22,22V7A1,1 0 0,0 21,6Z" />
    </svg>
    Merchandise
  </h2>
  <div class="communities">
    {{< communities/places "merchandise" >}}
  </div>
</div>

<div class="category left">
  <h2>
    <!-- TODO -->
    <svg style="width:24px;height:24px" viewBox="0 0 24 24">
        <title>Forum</title>
        <path fill="currentColor" d="M17,12V3A1,1 0 0,0 16,2H3A1,1 0 0,0 2,3V17L6,13H16A1,1 0 0,0 17,12M21,6H19V15H6V17A1,1 0 0,0 7,18H18L22,22V7A1,1 0 0,0 21,6Z" />
    </svg>
    Other
  </h2>
  <div class="communities">
    {{< communities/places "other" >}}
  </div>
</div>

## Adding your community
If you started a new Zig community, add to this page by [sending us a PR on GitHub](https://github.com/ziglang/www.ziglang.org)
