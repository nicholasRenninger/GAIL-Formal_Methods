from gym.envs.registration import register as gym_register
from gym_minigrid.envs.distshift import DistShiftEnv


class DistShift3(DistShiftEnv):
    def __init__(self, agent_start_pos=(1, 1), agent_start_dir=0):
        super().__init__(strip2_row=2, agent_start_pos=agent_start_pos,
                         agent_start_dir=agent_start_dir)


class DistShift4(DistShiftEnv):
    def __init__(self, agent_start_pos=(1, 1), agent_start_dir=0):
        super().__init__(strip2_row=5, agent_start_pos=agent_start_pos,
                         agent_start_dir=agent_start_dir)


# Register the environment with OpenAI gym
gym_register(
    id='MiniGrid-DistShift1-v1',
    entry_point='mod_envs.distshift:DistShift3',
    reward_threshold=0.95
)

gym_register(
    id='MiniGrid-DistShift2-v1',
    entry_point='mod_envs.distshift:DistShift4',
    reward_threshold=0.95
)
