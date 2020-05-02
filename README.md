# GAIL-Formal_Methods
A project experimenting with Generative Adversarial Imitation Learning and Formal Methods. 

Currently, the container-based environment has been tested to work on both windows and macOS, for machines with and without GPU support.

**Table of Contents**
* [About](https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/README.md#about)
* [Results](https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/README.md#results)
* [Methodology](https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/README.md#methodology)
* [Container Usage](https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/README.md#container-usage)
* [Installation](https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/README.md#installation)


## About

This repo contains the docker container and python code to fully experiment with [GAIL](https://stable-baselines.readthedocs.io/en/master/modules/gail.html). The whole experiment is contained in `GAIL_testing.ipynb`.

This project is based on [stable-baselines](https://stable-baselines.readthedocs.io/), [OpenAI Gym](https://github.com/openai/gym), [MiniGym](https://github.com/maximecb/gym-minigrid), [tensorflow](https://www.tensorflow.org/), [PRISM](https://www.prismmodelchecker.org/), and [wombats](https://github.com/nicholasRenninger/wombats)

*I will likely be changing to the [imitation](https://github.com/HumanCompatibleAI/imitation) library instead of stable-baselines for the GAIL implementation, as stable-baselines has decided to drop support for GAIL and also imitation has a PPO-based GAIL learned (definitely better than the older TRPO GAIL learner in stable-baselines).*



## Results

Here are some of the results from the GAIL experiments. Right now, I have a small bug somewhere in the training of GAIL, so it does not work - I've been trying to fix GAIL for weeks now. On the bright side, I think I just accidentally created an extremely powerful, general-purpose reinforcement learning algorithm to become the mathematically optimal game troll.


### Final Policies

Here are videos of the agents one of the DeepMind AI Safety environments. Here, the agent must get to the green goal while always avoiding the lava. 

**Expert Policy**

<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/ppo2_expert.gif">

**Imitation Learner Policy**

<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/learner.gif">

---

### Expert Demonstrator Training

To get an expert demonstrator for this environment, I used the [stable-baselines PPO2 implementation](https://stable-baselines.readthedocs.io/en/master/modules/ppo2.html). See the jupyter notebook for hyperparameters.

**Expert Episodic Reward**

*The final PPO2 training episodic, non-discounted reward as a function of training step.*
<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/expert_reward.png">

**Expert Entropy Loss**

*The final PPO2 entropy loss as a function of training step.*
<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/expert_loss.png">

---

### Imitation Learner Training

To train an imitation learner for this environment, I used the [stable-baselines GAIL implementation](https://stable-baselines.readthedocs.io/en/master/modules/gail.html). See the jupyter notebook for hyperparameters.

**Learner Episodic Reward**

*The final GAIL training episodic, non-discounted reward as a function of training step.*
<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/gail_episode_reward.png">

**Learner Discriminator Classification Loss**

*The final GAIL discriminator classification loss as a function of training step.*
<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/gail_discriminator_loss.png">

**Learner Internal Adversarial Reward**

*The final GAIL policy network discounted ”reward” signal from the descriminator as a function of training step.*
<img src="https://github.com/nicholasRenninger/GAIL-Formal_Methods/blob/master/results/gail_policy_net_reward_signal.png">


## Methodology

Basically, you first train an expert agent using RL (in this case with PPO2), collect sampled trajectories from the trained expert, and then train the imitation learner (in this case with GAIL) using those state-action pairs. GAIL has access to the environment as a dynamics model, but not the reward signal. It must train a robust policy using only the expert demonstrations as the specification of the task.



## Container Usage

* **run with a GPU-enabled image and start a jupyter notebook server with default network settings:**
  ./run_docker.sh --device=gpu

* **run with a CPU-only image and start a jupyter notebook server with default network settings:**
  ./run_docker.sh --device=cpu
  
* run with a GPU-enabled image with the jupyter notebook served over a desired host port, in this example, port 8008, with tensorboard configured to run on port 6996:
  ./run_docker.sh --device=gpu --jupyterport=8008 --tensorboardport=6996

* run with a GPU-enabled image and drop into the terminal:
  ./run_docker.sh --device=gpu bash

* run a bash command in a CPU-only image interactively:
  ./run_docker.sh --device=cpu $OPTIONAL_BASH_COMMAND_FOR_INTERACTIVE_MODE

* run a bash command in a GPU-enabled image interactively:
  ./run_docker.sh --device=gpu $OPTIONAL_BASH_COMMAND_FOR_INTERACTIVE_MODE

---

### Accessing the Jupyter and Tensorboard Servers

**To access the jupyter notebook:**
make sure you can access port 8008 on the host machine and then modify the generated jupyter url:
(e.g.) `http://localhost:8888/?token=TOKEN_STRING`

with the new, desired port number:
(e.g.) `http://localhost:8008/?token=TOKEN_STRING`

and paste this url into the host machine's browser. 

**To access tensorboard:**
make sure you can access port 6996 on the host machine and then modify the generated tensorboard  url:

(e.g. TensorBoard 1.15.0) `http://0.0.0.0:6006/`

with the new, desired port number:
(e.g.) `http://localhost:6996`

and paste this url into the host machine's browser. 


## Installation

This repo houses a docker container with `jupyter` and `tensorbaord` services running. If you have a NVIDIA GPU, check [here](https://developer.nvidia.com/cuda-gpus#compute) to see if your GPU can support CUDA. If so, then you can use the GPU-only instruction below.

### Install Docker and Pre-requisties

Follow steps one (and two if you have a CUDA-enabled GPU) from [this guide](https://www.tensorflow.org/install/docker) from tensorflow to prepare your computer for the tensorflow docker base container images. **Don't** actually install the tensorflow container, that will happen automatically later.

### Post-installation 

Follow the *nix [docker post-installation guide](https://docs.docker.com/engine/install/linux-postinstall/).

### Building the Container

Now that you have docker configured, you can need to clone this repo. Pick your favorite directory on your computer (mine is `/$HOME/Downloads` ofc) and run:
 ```bash
git clone --recurse-submodules https://github.com/nicholasRenninger/GAIL-Formal_Methods
cd GAIL-Formal_Methods
 ```
 
 The container builder uses `make`:
 * If you **have a CUDA-enabled GPU** and thus you followed step 2 of the docker install section above, then run:
 ```bash
make docker-gpu
```

* If you **don't have a CUDA-enabled GPU** and thus you **didn't** follow step 2 of the docker install section above, then run:
 ```bash
make docker-cpu
```
