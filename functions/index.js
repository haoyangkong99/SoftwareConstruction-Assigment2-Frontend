const functions = require("firebase-functions");
const admin = require('firebase-admin');
const stripe = require("stripe")('sk_test_51LYAgkHVnOUtb8pyw2GUpYgLJWt1mcwkyP4q1wl3zlUXYo88zAtvEpLhRfjYcGqD3qj2H7fHVXhweVdjh51jfJHp00PYz2An38')

admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    databaseURL: "https://your-project-id.firebaseio.com",
  });

exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
    try {
        let customerId;

        //Gets the customer who's email id matches the one sent by the client
        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });

        //Checks the if the customer exists, if not creates a new customer
        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.data.id;
        }

        //Creates a temporary secret key linked with the customer
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2022-11-15' }
        );

        //Creates a new payment intent with amount passed in from the client
        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(req.body.amount),
            currency: 'myr',
            customer: customerId,
        })

        res.status(200).send({
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            payment_method_types: ["card"],
            application_fee_amount: parseInt(req.body.amount) * 0.1, // 10% application fee
            transfer_data: {
              destination: req.body.destination, // ID of the connected account
            },
            success: true,
        })

    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
});
exports.stripePaymentIntentToConnectedAccountRequest = functions.https.onRequest(async (req, res) => {
    try {
      let customerId;

      //Gets the customer who's email id matches the one sent by the client
      const customerList = await stripe.customers.list({
        email: req.body.email,
        limit: 1,
      });

      //Checks the if the customer exists, if not creates a new customer
      if (customerList.data.length !== 0) {
        customerId = customerList.data[0].id;
      } else {
        const customer = await stripe.customers.create({
          email: req.body.email,
        });
        customerId = customer.id;
      }

      //Creates a temporary secret key linked with the customer
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: "2022-11-15" }
      );

      //Creates a new payment intent with amount passed in from the client
      const paymentIntent = await stripe.paymentIntents.create({
        amount: parseInt(req.body.amount),
        currency: "myr",
        customer: customerId,
        payment_method_types: ["card"],
        application_fee_amount: parseInt(req.body.amount) * 0.1, // 10% application fee
        transfer_data: {
          destination: req.body.destination, // ID of the connected account
        },
      });

      res.status(200).send({
        paymentIntent: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customer: customerId,
        success: true,
      });
    } catch (error) {
      res.status(404).send({ success: false, error: error.message });
    }
  });

  exports.getStripeStandardAccount = functions.https.onRequest(async (req, res) => {
    try {
      const accountID = req.body.accountID;
      const account = await stripe.accounts.retrieve(accountID);

      await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("account").set(account);
      res.status(200).json({
        success: true,
        account: account
      })

    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
  });
  exports.generateOnboardingLink = functions.https.onRequest(async (req, res) => {
    try {
      const accountID = req.body.accountID;
      const account = await stripe.accounts.retrieve(accountID);
        const accountLinks = await stripe.accountLinks.create({
            account: account.id,
            refresh_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
            return_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
            type: "account_onboarding"
          });
          const accountLinksData = {
            ...accountLinks,
            status: true
          };
          await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("accountLinks").set(accountLinksData);
      res.status(200).json({
        success: true,
        link: accountLinks.url
      })

    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
  });
  exports.generateUpdateAccountLink = functions.https.onRequest(async (req, res) => {
    try {
        const accountLinks = await stripe.accountLinks.create({
            account: req.body.accountId,
            refresh_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
            return_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
            type: "account_update"
          });
          const accountLinksData = {
            ...accountLinks,
            status: true
          };
          await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("accountLinks").set(accountLinksData);
      res.status(200).json({
        success: true,
        link: accountLinks.url
      })

    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
  });

exports.createStripeStandardAccount = functions.https.onRequest(async (req, res) => {
    try {
      const account = await stripe.accounts.create({
        type: "standard",
        email: req.body.email,

      });

      const accountLinks = await stripe.accountLinks.create({
        account: account.id,
        refresh_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
        return_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
        type: "account_onboarding"
      });
      const accountLinksData = {
        ...accountLinks,
        status: true
      };

      await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("account").set(account);
      await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("accountLinks").set(accountLinksData);

      res.status(200).json({
        success: true,
        url: accountLinks.url
      })

    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
  });


exports.reauth = functions.https.onRequest(async (req, res) => {
    try {


      const accountLinks = await stripe.accountLinks.create({
        account: account.id,
        refresh_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
        return_url: `https://us-central1-utm-let-go.cloudfunctions.net/reauth?account_id=${account.id}`,
        type: "account_onboarding"
      });
      const accountLinksData = {
        ...accountLinks,
        status: true
      };

      await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("account").set(account);
      await admin.firestore().collection(`user/${req.body.documentID}/stripe`).doc("accountLinks").set(accountLinksData);

      res.status(200).json({
        success: true,
        url: accountLinks.url
      })
    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
  });
