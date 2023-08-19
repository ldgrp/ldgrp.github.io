--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Maybe (fromMaybe)
import Data.Monoid (mappend)
import Hakyll
import System.FilePath.Posix  ((</>))

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "fonts/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "scripts/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "404.html" $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "ideas/*.md" $ do
        route $ setExtension "html"
        compile $ pandocCompiler 
                >>= loadAndApplyTemplate "templates/post.html"    ideaCtx
                >>= loadAndApplyTemplate "templates/default.html" ideaCtx
                >>= relativizeUrls
    
    match "posts/external/*.md" $ do
        route   $ metadataRoute urlRoute
        compile pandocCompiler

    match "posts/*.md" $ do
        route removeDateRoute
        compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    match "recipes/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    recipeCtx
                >>= loadAndApplyTemplate "templates/default.html" recipeCtx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["ideas.html"] $ do
        route idRoute
        compile $ makeItem ""
                >>= loadAndApplyTemplate "templates/ideas.html"   ideasCtx
                >>= loadAndApplyTemplate "templates/default.html" ideasCtx
                >>= relativizeUrls


    match "index.md" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
entryCtx :: String -> Context String
entryCtx entryType =
    constField "entry-type" entryType `mappend`
    dateField "date" "%d %b %Y" `mappend`
    defaultContext

postCtx :: Context String
postCtx = entryCtx "post"

ideaCtx :: Context String
ideaCtx = entryCtx "idea"

recipeCtx :: Context String
recipeCtx = entryCtx "recipe"

--------------------------------------------------------------------------------
posts = do
    x <- loadAll "posts/*.md"
    y <- loadAll "posts/external/*.md"
    pure (x ++ y)

ideas = loadAll "ideas/*.md"
    
--------------------------------------------------------------------------------
archiveCtx :: Context String
archiveCtx =
    listField "posts" postCtx (recentFirst =<< posts) `mappend`
    listField "ideas" ideaCtx (recentFirst =<< ideas) `mappend`
    constField "title" "Archive" `mappend`
    defaultContext
    
indexCtx :: Context String
indexCtx =
    listField "posts" postCtx (recentFirst =<< posts) `mappend`
    listField "ideas" ideaCtx (recentFirst =<< ideas) `mappend`
    constField "title" "Leo Orpilla III" `mappend`
    defaultContext

ideasCtx :: Context String
ideasCtx =
    listField "ideas" ideaCtx (recentFirst =<< ideas) `mappend`
    constField "title" "Ideas" `mappend`
    defaultContext

--------------------------------------------------------------------------------
removeDateRoute :: Routes
removeDateRoute = 
  composeRoutes (gsubRoute "[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ const "") (setExtension "html")

urlRoute :: Metadata -> Routes
urlRoute = constRoute . fromMaybe "\\#" . lookupString "url"