import os
import base64
from pathlib import Path

from IPython import display as ipythondisplay
from stable_baselines.common.vec_env import VecVideoRecorder, DummyVecEnv

import gym

# Set up fake display; otherwise rendering will fail
os.system("Xvfb :1 -screen 0 1024x768x24 &")
os.environ['DISPLAY'] = ':1'


def show_videos(video_path='', prefix=''):
    """
    Taken from https://github.com/eleurent/highway-env

    :param video_path: (str) Path to the folder containing videos
    :param prefix: (str) Filter the video, showing only the only starting with
                       this prefix
    """

    html = []
    for mp4 in Path(video_path).glob("{}*.mp4".format(prefix)):
        video_b64 = base64.b64encode(mp4.read_bytes())
        html.append('''<video alt="{}" autoplay
                    loop controls style="height: 400px;">
                    <source src="data:video/mp4;base64,{}" type="video/mp4" />
                </video>'''.format(mp4, video_b64.decode('ascii')))
        ipythondisplay.display(ipythondisplay.HTML(data="<br>".join(html)))


# We will record a video using the
# stable_baselines VecVideoRecorder wrapper
def record_video(model, env_id=None, eval_env=None,
                 max_video_length=500, video_prefix='',
                 video_folder='videos/', break_early=False):
    """
    :param env_id: (str)
    :param model: (RL model)
    :param max_video_length: (int)
    :param video_prefix: (str)
    :param video_folder: (str)
    """

    # directly passing an environment overrides passing in an env
    if eval_env is None:
        eval_env = DummyVecEnv([lambda: gym.make(env_id)])

    # Start the video at step=0 and record 500 steps
    eval_env = VecVideoRecorder(eval_env, video_folder=video_folder,
                                record_video_trigger=lambda step: step == 0,
                                video_length=max_video_length,
                                name_prefix=video_prefix)

    obs = eval_env.reset()
    for _ in range(max_video_length):
        action, _ = model.predict(obs)
        obs, _, done, _ = eval_env.step(action)

        if done and break_early:
            break

    # Close the video recorder
    eval_env.close()
