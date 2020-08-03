DEPLOY="docs/"
BUILD="_site/"

export NODE_ENV=production

build() {
    COMMIT=$(git rev-parse HEAD)

    echo "Building css..."
    npm run build:css

    echo "Building site..."
    cabal clean
    cabal build
    cabal exec site build

    rm -rf $DEPLOY
    mkdir $DEPLOY

    cp -r "$BUILD"/* $DEPLOY

    echo "Static site at $DEPLOY"

    git add $DEPLOY

    git commit -m "Add generated site from $COMMIT"

    git push origin develop
}

build
