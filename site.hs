--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
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

    match "posts/*.md" $ do
        route removeDateRoute
        compile $
            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    match "recipes/*" $ do
        route $ setExtension "html"
        compile $
            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    recipeCtx
                >>= loadAndApplyTemplate "templates/default.html" recipeCtx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.md" $ do
        route $ setExtension "html"
        compile $ do

            pandocCompiler
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%d %b %Y" `mappend`
    defaultContext

recipeCtx :: Context String
recipeCtx = postCtx

archiveCtx :: Context String
archiveCtx =
    listField "posts" postCtx (recentFirst =<< loadAll "posts/*.md") `mappend`
    constField "title" "Archive"                                     `mappend`
    defaultContext
    
indexCtx :: Context String
indexCtx =
    listField "posts" postCtx (recentFirst =<< loadAll "posts/*.md") `mappend`
    constField "title" "Leo Orpilla III" `mappend`
    defaultContext

removeDateRoute :: Routes
removeDateRoute = 
  composeRoutes (gsubRoute "[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ const "") (setExtension "html")