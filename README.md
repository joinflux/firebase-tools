# GitHub Actions for Firebase

This Action for [firebase-tools](https://github.com/firebase/firebase-tools)
enables arbitrary actions with the `firebase` command-line client and it provides
a node environment with with firebase-tools installed and ready to be consumed.

## Using

To use this action, make sure to refer to: `joinflux/firebase-tools`

We also try to release tagged versions that you can refer to:
`joinflux/firebase-tools@v14.6.0`

Alternatively, refer to `master` to get the most up to date version. However
plese be aware that it might be unstable: `joinflux/firebase-tools@master`

### Complete Example

```
  - name: Deploy to Firebase
    uses: joinflux/firebase-tools@v14.6.0
    with:
      args: deploy --only hosting
    env:
      FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## Inputs

* `args` - **Required**. This is the arguments you want to use for the `firebase` cli

## Environment variables

* `FIREBASE_TOKEN` - **Required if GCP_SA_KEY is not set**. The token to use for
  authentication. This token can be aquired through the `firebase login:ci`
  command.

* `GCP_SA_KEY` - **Required if FIREBASE_TOKEN is not set**. A base64 encoded
  private key (json format) for a Service Account with the `Firebase Admin` role
  in the project. If you're deploying functions, you would also need the `Cloud
  Functions Developer` role.  Since the deploy service account is using the App
  Engine default service account in the deploy process, it also needs the
  `Service Account User` role.  If you're only doing Hosting, `Firebase Hosting
  Admin` is enough.

* `PROJECT_ID` - **Optional**. To specify a specific project to use for all
  commands. Not required if you specify a project in your `.firebaserc` file.

* `PROJECT_PATH` - **Optional**. The path to the folder containing
  `firebase.json` if it doesn't exist at the root of your repository. e.g.
  `./my-app`

## Example

To authenticate with Firebase, and deploy to Firebase Hosting:

```yaml
name: Build and Deploy
on:
  push:
    branches:
      - master

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@master
      - name: Install Dependencies
        run: npm install
      - name: Build
        run: npm run build-prod
      - name: Archive Production Artifact
        uses: actions/upload-artifact@master
        with:
          name: dist
          path: dist
  deploy:
    name: Deploy
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@master
      - name: Download Artifact
        uses: actions/download-artifact@master
        with:
          name: dist
          path: dist
      - name: Deploy to Firebase
        uses: joinflux/firebase-tools@master
        with:
          args: deploy --only hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

Alternatively:

```yaml
        env:
          GCP_SA_KEY: ${{ secrets.GCP_SA_KEY }}
```

If you have multiple hosting environments you can specify which one in the args line.
e.g. `args: deploy --only hosting:[environment name]`

If you want to add a message to a deployment (e.g. the Git commit message) you need to take extra care and escape the quotes or the YAML breaks.

```yaml
        with:
          args: deploy --message \"${{ github.event.head_commit.message }}\"
```

### Running a script

If you'd like to run a script that depends on `firebase-tools`, simply use the
relative path to the script:

```js
// ./my-script.js 
const firebase = require("firebase-tools")
// do something with firebase
```

```yaml
      - name: Run script
        uses: joinflux/firebase-tools@v14.6.0
        with:
          args: "./my-script.sh"
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## License

The Dockerfile and associated scripts and documentation in this project are released under the [MIT License](LICENSE).

### Recommendation

If you decide to do seperate jobs for build and deployment (which is probably advisable), then make sure to clone your repo as the Firebase-cli requires the firebase repo to deploy (specifically the `firebase.json`)
