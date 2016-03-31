# deep-rl
Collection of Deep Reinforcement Learning algorithms

## Dependencies
* torch7
* Love2D
* [HadronCollider](http://hc.readthedocs.org/en/latest/index.html#)

# Notes
* An SL network pre-trained on "good behavior" would help a lot, but you would need access to a very 
diverse set of environments and scenarios to avoid overfitting 
* Limited amounts of data/simulation is available - So, how to initialize the weights of the network? Random sampling from Uniform
* Use DDPG - How is this different than REINFORCE? DPG uses a deterministc policy, as opposed to a stochastic policy

# What would I like to accomplish? 
* DNN used to approximate the Q function with action-replay and target network
* Will there be problems with learning a representation of the policy? Maybe
* Reactionary controller is implemented for baseline

