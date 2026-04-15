use dioxus::{html::img, prelude::*};

#[derive(Debug, Clone, Routable, PartialEq)]
#[rustfmt::skip]
enum Route {
    #[layout(Navbar)]
    #[route("/")]
    Home {},
}

const FAVICON: Asset = asset!("/assets/favicon.ico");
const MAIN_CSS: Asset = asset!("/assets/main.css");
const HARUKI7049: Asset = asset!("/assets/haruki7049.png");

#[component]
pub fn App() -> Element {
    rsx! {
        document::Link { rel: "icon", href: FAVICON }
        document::Link { rel: "stylesheet", href: MAIN_CSS }
        Router::<Route> {}
    }
}

/// Home page
#[component]
fn Home() -> Element {
    rsx! {
        div {
            id: "greeting",

            Greeting { }
            ProjectsList { }
        }
    }
}

#[component]
fn Greeting() -> Element {
    rsx! {
        div {
            id: "greeting",

            img { src: HARUKI7049 }
            h1 { "Haruki7049" }
            p { "A Rustacean, Zig user, and heavy Nix / NixOS user." }
        }
    }
}

#[component]
fn ProjectsList() -> Element {
    rsx! {
        div {
            id: "projects-list",

            h1 { "Projects" }
            ul {
                li { AboutLightmix { } }
            }
        }
    }
}

#[component]
fn AboutLightmix() -> Element {
    rsx! {
        div {
            class: "about_project",
            p { "lightmix: Audio processing library written by Zig-lang" }
            a { href: "https://github.com/haruki7049/lightmix", "GitHub" }
        }
    }
}

/// Shared navbar component.
#[component]
fn Navbar() -> Element {
    rsx! {
        div {
            id: "navbar",
            Link {
                to: Route::Home {},
                "Home"
            }
        }
        Outlet::<Route> {}
    }
}
