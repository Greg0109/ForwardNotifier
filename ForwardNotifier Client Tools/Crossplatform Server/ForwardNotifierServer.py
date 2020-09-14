#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import platform
import subprocess
import base64
import requests
import re
import time

if platform.system() == "Windows":
    from PIL import Image  # convert to ico
    from win10toast import ToastNotifier
    toaster = ToastNotifier()

port = 8000

forwardnotifiericon = "iVBORw0KGgoAAAANSUhEUgAAADoAAAA6CAYAAADhu0ooAAASJXpUWHRSYXcgcHJvZmlsZSB0eXBlIGV4aWYAAHjarZppdmOpskb/M4o7BLqgGQ4EsNabwRv+3YFkZdpplzNvZbpsqaQjDkTzNSC3////jvsP/ySV7LLUVnopnn+55x4HT5p//Ov3b/D5/r3/0ni+F96/7l5vRF5KduXjf+vz9TB4XX584O0eYb5/3bXnO7E9BwqvgR8zsDvb8/XzJHk9Pl4P+TlQ348npbf681TncyB9Xnin8vzNr2k9Huz/3bsXKlFawo1SjDuF5O/f9phBevwOfgt/Yyrx7RX+uftSew5GQN4t7+3R+58D9C7Ib8/cx+i/nn0IfhzP19OHWJZnjHjy6RtBPryeXreJ78rhNaP4/o25Q/plOc/fc1Y7Zz9WN3IhouVZUTfY4W0YLpyEPN2PFX4qv8Lzen86P80Pr6R8efWTHw09RG59XMhhhRFO2PdRgzLFHHesPMaoMd3XWqqxRyVHIWX7CSfW1NNKjWRp3I7M5RRfcwn3vv3eT0PjzitwaQwMFvjIlz/un978kx93jlqIgm+vWDGvaHXNNCxz9perSEg4z7zJDfDbzzP9/qf6oVTJoNwwNxY4/HwMMSX8qK1085y4Tnh8tFBwdT0HIETcW5hMSGTAl5AklOBrjDUE4thI0GDmMeU4yUAQiYtJxpzoFldji3ZvPlPDvTZKLNFeBptIBKiVKrnpaZCsnIX6qblRQ0OSZBEpUqU56TIKCFeklFKLgdyoqeYqtdRaW+11tNRyk1Zaba31NnrsCQyUXnrtrfc+RnSDGw3GGlw/eGXGmWaeMsuss80+h1I+mlW0aNWmXceKKy1gYpVVV1t9jR3cBil23rLLrrvtvseh1k46+cgpp552+hmvrD2z+svPH2QtPLMWb6bsuvrKGq+6Wt+GCAYnYjkjYzEHMl4tAxR0tJz5FnKOljnLme+RppDIJMVy41awjJHCvEOUE165+5G538qbk/ZbeYvfZc5Z6v5G5hyp+zVvn2RtGc/pzdijCy2mPtF9vL/bcHGuUDWs7Q+UK3mxpNC2jl0WqLSISg0z7hOHzdAaghuPUk8aazTxXVhcVJd1jCVtxbZWV9mtDjncp6wyE2x3dq09Mdt9FmOv1TT2snsPu8ueYSSiOM90gGBZe829WNvpMfe1WObSo5pP1n5kLN9SbivFVar0sU7eMzN9OZPyVT+GJtfUCHZMhl87ANLEe+qUQrJa0zzHHDQ5sJAlyBog8H1KHb57dB9f+PPHQDT0uLtA2VoI7F2f1K4Qgq1vk2v1rK+dTCrrqinPs5Wcl7rS0X3SpBIYQd2aEzYQvwhBJcBrxdH1wFq9V6GcVg2jysgrzrp27SytlKQlEU+pNMUkHDO6qTUTwg0hxd1LO5JrAxvJ30RBHF+nMsamaCl2qn9R+adQv4Sf2reRJqUN9zPs4hOdNfFOI+otj6az01GDfhpa+G+3FVY8mXKeMk6qZyaSzerAXdbrqlD3tOQefCyMUygpsDeumgUqrSyw6AwytbQ9O9hhRIuAGUzKM+3S+eQaLm2dRReFTrCYem+7hq6EZ+8yC0GbCgvTT4MLBnFtdBCiqbE++2y+uRNXS9f2eG467n9+dL91oSTqgvVS0MKcapNa86ReFExhvYleEwRg6lR6XZJuKLMQvzOzXdeJaiKqVYqSw04eDqV/aib+q9q4QAmldRwrJRLd6mpNIqlcTvTRJyWISlONZ4KAoIoc8gtEaK4zAnoTYixtxDb2Sq4jjO25/5ePzv/VgaqBlzUNTJQ35ABW5TkXDANCUDw9HFTZCQMkpaZmRPTlU7IkgBoYLcmtYzCmh8uUrjzUHbGjky+I0jk8NsPatjIZaKQrHSp4q6IMRPbzavfL5cEUZ73DJ03M4lzEBAoXbDSH/2wYmPbvDHO6+zvDICL+zjA3Rn9jGPNrf2WYdtyfD0OTUTsI27g8diL0ZDXmKDIQN5cVJl2IOG+6hHqDD5TajDKRMRcEEobg6+J2jydDBQBVeGBS4Q27kgoVPkMG4zbCZc+xj08LPXF5+NDic4MTZ1DE8KIDXUGbLsnmXmYuYa9YkEdgKMg4V1LghNmskpWZN8kzwEZBgaG09kSLsR5axKxVOYBSo58m6gOpkmWhtUbbzcANedJRnDBBqnUaiZ2yQx4o7ZIbUmExf0dob3xNahZry3RmRAUhHhp/YAr+QDttANKoCdMpwtPYadVs/u3Rqc5adT5btU9y+Uroc3aE8zlC6iWttxl8nID7egaW+jOn/zCBCxTM4sP9qew7hd+YwKvGyrPG3s3AfT+FH2j1TyFwvxuD70LgfjcG34XADb9GKn1v3xDDihvzddc7B8aSo6mOagy/EXvamzYUQZA4NhLH+51AdiTiQkSsg2o16sMA05LI3Nx4eyE+Uao9R8hwBT5RUzF2LeukEnAQpl7LEawEBevwHEB+Q6+t4g+iCeEKvXYq+WyfRKHnhSvco86r6ZGpIU44uevSZxsjdV37sqOndU6FZZDmFiP49iCKkFNJIGVN+0YOWYLXjxdqV0fVorUOYjqeXjdSqGusN1dIxbbXg5pPVwDAj3sz/+7RvT1pGJumtn/RcyAmqFJ0cUFjIwx2ZQiiwoonVEpprpRYLM2/PFS68nZh7laiNISer0oOgTukIJcSbNPjAT8laJUV9EDIwYBQudOdDpIGhHg3o58ekXWntUdTeAKBBbkxiq/wZKtsSJfgELfV42zYrDOierQl+taWMK+fsjqixGt+jG6NUz6NzX1ElRpBVrMdJHtR3RvEVrQ1xUIxnF3inRl69JyCaMw0ic0OlwHQdhPNvlsHgEf2RkwUyb31rlCGflITaUhJZodAa+oGp+snho9xkIK0iDEFCqwktPFsOQLeqOFMTWcUCxNEFzKvifgrHSvYRJbWFmtD/E26ArtF/4jDieEtCc6WbjpzSo1p9NNM328wf+Iu9m7dunwRSQnI7c3c8dI0IB29ccTb4SBgOagkYsDmKpTgnnunxnTMI2aPTqcrrVbKFMqpYBk6Bh8qbBXS6kFrENfhQnR4NN+MutRt1leomo2V5eZSbrP6HLGNI89GM2JaU4j4G4jFjOQsvrmYYkQuA1lC8AwGsD0B3xCybr8p3ID0w+kCF+Uw39ZR3GY6wYNupakJQIguQehKO8BhycyNYLpxTgmjT8vhJ4+QR1pIu+A+UqKZIksDYAyTMiuDjPNw6MY+QMyPtlDlUcDW328lbO1NEXcrwB0Nx5kN9YcQIdj9FiCQg4knP7fdV9+xRNMpkdCPN0PbavrSlzp5X8S3hKlkihj6/wqR4oOezK+CO3Qw3I+52CnfLgsUyr31STjd8s7ZtLzpqoit6wRJurSMd809FCxvJSkO1K+DOFGmCbPYLWYJaA2254HEwXL4gERbhJq4LBwgznfPdGIKDYO5D8SEYtv9OjiaYG31OwD2CJkIMscaYAYMUgSTH013Mlf8aPo5Rx0C2RB9R1hbWOo7fivaBmu1uZudMDQo3TQV5pIclASEel2VKyKxw4RNq/XKbGERGI9ukSMQGHOmdXCZd6sEIiFWI0V0EtaYxC7qZOaaDCfbsuQ3z/234anjnQjRqWCHdWdmqlDftC0meS6oh/Z9dbnPy+vPq8t9se3xx9XlPi+v36guAR2UyzLQmspyELiFCJm6GjQoJdChnfrp1fYTG1XiQZR9ASUXSsP2heNIZoxp90ig6h7J1QgAAzWCiz6wjcV5Paacsb4E92I6AVxLEfGkyJY8JVeAkao9tk+Vi9NYMv7AdufMiych07ZVA+iRuIxZ8Bo2y98K81II+VR9bH6gblrHhXpzpxSk7LCbTcTOAoDvBfwjBJDQphd1WWTpgkG59X1QJHyWD6UDgett4hHp/gC5s+IOPhaaZxgxyrYtJTgMASWmCATeV7oI+18XaZx5bz5uNTFsFwCl7xDz2IFq3CBGd7VJpCJPSpHp4HIQ+vkGhaqmsiEyVkwemIr6KKYNSs3ZIb2qN9CHbYz44DlbdWkJV50AW3RcpzBm8KVNZKfVUzV26VYcMHy1TY/g4BcUk6393GOze97DoLCOZhNlm6ZRE3hBzHs86oiHDxsxDpaQExARuwSq1fJp98yvGjZZckWJ1TAF/hQlJ0ujrQjFg/RdKrX1Nq2Q5xn7uZUEG6l+uRn0Un5X99ETM2JqTPc9O/cTYQLs2aVgEJLg0DV5h3TNK9WeDVXufRXFttcPKkLXIqNJwrA5zvm4n5cxKzqNkHcNQG+jLlHHTH9Wb0IZYYMXIe2Y2AGaZ4gvNe4rA/gCB4uBEfw9Fl6yKrJ40ljnCKZzsjZZd8UFHelGYdm50rYN07hJTbYzmY2IyLaROaaJApSsHRW8ssaHulfTBEQEKdyTK5vGpgQkXSddUFEa11Pm9a83aD9ipfuOin8XK913VEwl2JkwoduGLrM8NKQZgEq5D/MWZB6CJM+7UrspPZyhta6adFsY+IiyGahsihYNRnmWDr+IxII0wh5kERiXAbZbVKTH8i/YLkq5263aaAZ0WxnZlApk2/qiqB6kktNnOtl9Lpw/PvpjwtZ4X9RKGNFZjTcLmtwwLCEi8BpKtpCkGfwGcTP2davtgNLVB0h6KG2xc49pTAosgEiYxAOxQ7RCAWwXGZxI2ha1AmsQZMzQCNKYrAw+40HyiGNErD8JE23366Td6wXxqnidHk5OmSgCUnmDeCwAUEPk34Kb6HM7LMoJxZBsd1koKLETP7gI6Q6edXyILQKpzIgAu9nkbCciWCFUD9SD7Om2MCUtyGj0EElfttmEpzVhTRNRI2kVqm3bFheul/THBYRV206qADYBEoTs/zpQOIKyWC29jSMEzWZrc9d5H7kHeMRKqCX6g0/V5VH6HpuFKK+IoP0G/Ci50guU1xLGYQRPf9aAi/GDhKO8HdIJnIfXusVh+xFMYaPU4G/yzWy2sYk5djuIixS6pwYGQjHvFQEVb/lMjlw2KhxQmjAlvmT7A8XiP8BtkPumfBpIL3TBtH3zhEdici1Pk1EegKuNOjJdlrpOXgLg6OFqxxgYGLCGfkBCICYjFgbuwRsc/ISZ4r7uFkseOEFIZjoj3f2WdpQeS5lg4mEyMGC3/UA76kDTQFI4ilWZh4Ec3g+3s2sXAwJTI6D6DF8k9bucwk+PpKr7uTyozV/GAvR+Gs248zXeuwpxP5dIThjMGY2Oy/Hm5+xo57DYWKgBaxZQrD/QGUc2LY80S2K9jm6hiqC2gmrRsBZxNTnC1ApSFxQA/MmqtR8yCPP2xM72rw8PICdfBYcHzDREPs+E9ANHywwm9hHe8uHxzYt7KuYLDr0icmBo1rPawcRgbjCc2Q6hkUp497Ht/Hg4gBr2SYnMdZwEwESBN0CaXhCUbLzKEfSm3hjWZBsmYmCbNYB7dNcC3Pt2M0YTjjUBn8isQFdVOwgHNPBWIBL07ylEq3m0mW2xVOAprl0gjCC+cCei7KBwhk+wpjdlLXbmjAqzY0M7YPvuMPT16P71oejfHwjDNLzpenTSWcNOAKnXRA/dE0BpZKJftar3BFCjbUvUZN/1qIjnDZtiDh3PlcyhXmYyggK59iiTEXPrO0+MSNEI1ZOdqGjBQH0XA3oCndEAxNTTEA7UArTKsP2QYWeLtkNKC5Qi+tyDyjt/T6Huuwt+99HdE0DgMaPo9+NgYEzQmSXfI0CAiyWjGfyhSiv1gekAsfDp6D+8+KQfCzFKgwoKiq6BYcFFBZDzI5b8z0DMeGJpR9ZUuIWyPo4W8fDN4hM6/IwJcdoLV1t8QNZqzh2wt0PpalaaARBUUZupEnwyuGGSc9p3D9rGh6Fk7QjSBHsHLir+ZRt4iH2HEHNlhyPA+LAdIgoj2yE0Gqp2OrCuBJcU6gLkgw46rY0VRbbSZKrVGNqH+w2CUE2I9bMwH+j20ezLDNUqax470ACp42DKEM5YRhRc57ZZX6CkcMkpRK1au9q2FXjQsMbD9jxoQWwTsyozGiU9v58Q5xD7SkWYD5ctf+Ec2v3DBZK37bFnBZv7CLMtZhpDF+g1YjhBFBAjaYtldGcca8tLBljhsTxy1aO/ywOz0MXPaHTbORzg//0uCK0UkHf3uyDrONtkvF8GaZBFsz08FdurVGME8Onx7QT4nZ+Ts4llDG9odjBlNx819yIQpPlpw+YLx/frKtUE/7C9UiiO+mIJtuMDsTEnOwqmnTGCXeJjLwa6Q5+6/wL76UwNm4mvgAAAAYRpQ0NQSUNDIHByb2ZpbGUAAHicfZE9SMNAHMVfW7UiFUE7SHHIUJ0siBZx1CoUoUKoFVp1MLn0C5o0JCkujoJrwcGPxaqDi7OuDq6CIPgB4uTopOgiJf4vKbSI8eC4H+/uPe7eAf5Ghalm1wSgapaRTiaEbG5VCL6iBxEMQkBcYqY+J4opeI6ve/j4ehfjWd7n/hz9St5kgE8gnmW6YRFvEE9vWjrnfeIwK0kK8TnxuEEXJH7kuuzyG+eiw36eGTYy6XniMLFQ7GC5g1nJUInjxFFF1Sjfn3VZ4bzFWa3UWOue/IWhvLayzHWaI0hiEUsQqSMZNZRRgYUYrRopJtK0n/DwRxy/SC6ZXGUwciygChWS4wf/g9/dmoWpSTcplAC6X2z7YxQI7gLNum1/H9t28wQIPANXWttfbQAzn6TX21r0CBjYBi6u25q8B1zuAMNPumRIjhSg6S8UgPcz+qYcMHQL9K25vbX2cfoAZKir1A1wcAiMFSl73ePdvZ29/Xum1d8PuOFyw8MW66IAABBuaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA0LjQuMC1FeGl2MiI+CiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICB4bWxuczppcHRjRXh0PSJodHRwOi8vaXB0Yy5vcmcvc3RkL0lwdGM0eG1wRXh0LzIwMDgtMDItMjkvIgogICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIgogICAgeG1sbnM6cGx1cz0iaHR0cDovL25zLnVzZXBsdXMub3JnL2xkZi94bXAvMS4wLyIKICAgIHhtbG5zOkdJTVA9Imh0dHA6Ly93d3cuZ2ltcC5vcmcveG1wLyIKICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgIHhtbG5zOmV4aWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIgogICAgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICB4bXBNTTpEb2N1bWVudElEPSJnaW1wOmRvY2lkOmdpbXA6NTVhYjc3YzItMzJjNi00NzBjLWEwNWItNzRiNDhlYTY1NjU3IgogICB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmIxZTkyOThmLWE4ZjUtNGY3NC1iNjA0LTUwYWE0NjY2ODQ2YiIKICAgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmZjZjhkNDFlLTFhNzEtNDk3NS05MTE0LWYyYjcxZjNiYWM1OCIKICAgR0lNUDpBUEk9IjIuMCIKICAgR0lNUDpQbGF0Zm9ybT0iTGludXgiCiAgIEdJTVA6VGltZVN0YW1wPSIxNTkzMTk2NDExNTQwODQ0IgogICBHSU1QOlZlcnNpb249IjIuMTAuMTgiCiAgIGRjOkZvcm1hdD0iaW1hZ2UvcG5nIgogICBleGlmOlN1YnNlY1RpbWVEaWdpdGl6ZWQ9IjI0MSIKICAgZXhpZjpTdWJzZWNUaW1lT3JpZ2luYWw9IjI0MSIKICAgcGhvdG9zaG9wOkRhdGVDcmVhdGVkPSIyMDIwLTA2LTI2VDIwOjMwOjI5IgogICB4bXA6Q3JlYXRlRGF0ZT0iMjAyMC0wNi0yNlQyMDozMDoyOSIKICAgeG1wOkNyZWF0b3JUb29sPSJHSU1QIDIuMTAiCiAgIHhtcDpNb2RpZnlEYXRlPSIyMDIwLTA2LTI2VDIwOjMwOjI5Ij4KICAgPGlwdGNFeHQ6TG9jYXRpb25DcmVhdGVkPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6TG9jYXRpb25DcmVhdGVkPgogICA8aXB0Y0V4dDpMb2NhdGlvblNob3duPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6TG9jYXRpb25TaG93bj4KICAgPGlwdGNFeHQ6QXJ0d29ya09yT2JqZWN0PgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6QXJ0d29ya09yT2JqZWN0PgogICA8aXB0Y0V4dDpSZWdpc3RyeUlkPgogICAgPHJkZjpCYWcvPgogICA8L2lwdGNFeHQ6UmVnaXN0cnlJZD4KICAgPHhtcE1NOkhpc3Rvcnk+CiAgICA8cmRmOlNlcT4KICAgICA8cmRmOmxpCiAgICAgIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiCiAgICAgIHN0RXZ0OmNoYW5nZWQ9Ii8iCiAgICAgIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6Y2M1MmU0ZTktMWZlMS00N2Y4LWFiYTktNDFjNzE1YzA2YjZiIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJHaW1wIDIuMTAgKExpbnV4KSIKICAgICAgc3RFdnQ6d2hlbj0iKzAyOjAwIi8+CiAgICA8L3JkZjpTZXE+CiAgIDwveG1wTU06SGlzdG9yeT4KICAgPHBsdXM6SW1hZ2VTdXBwbGllcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkltYWdlU3VwcGxpZXI+CiAgIDxwbHVzOkltYWdlQ3JlYXRvcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkltYWdlQ3JlYXRvcj4KICAgPHBsdXM6Q29weXJpZ2h0T3duZXI+CiAgICA8cmRmOlNlcS8+CiAgIDwvcGx1czpDb3B5cmlnaHRPd25lcj4KICAgPHBsdXM6TGljZW5zb3I+CiAgICA8cmRmOlNlcS8+CiAgIDwvcGx1czpMaWNlbnNvcj4KICA8L3JkZjpEZXNjcmlwdGlvbj4KIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/PlljaEQAAAAGYktHRAD/AP8A/6C9p5MAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQfkBhoSIR/v0N5nAAAEHUlEQVRo3uWbX0wcVRSHv5kdlt0VsdFqSqNsokWMlRpjtWqphIAvjdSkKQkx8UWTNtpEoQm++GBMTEzFCI3xyRceKmrEql1ropS2KChNFSqQpsSGZheKlMVYkP03O7PXh90KdRe7mzDDzPB7vDM3d749955z7t1zJVbQ9oOfU1axowbYC+wEqgA31pIKjAIDwLE/fj/b98uHjTlflHI1NnSE6oD3gW3YSyPAoUBzee//gu75IOQSOm1AC/ZWuyTTevzVcj0LtKFj0gXiU2AfzlA3gqZASxpWXmoXbQ6CBNiHRNsNFs2syZM4U/WB5vJeqaalh1J/5W82dDx5O6iF4PjDcqm/ssbBkADbSv2VNXImTjpde+VMMuB07ZQzGY/TVSVbMK0zQm6ZdaJ1A6oUPNk3ymzZ6MLrltbkgxNJwfisztifKWNAN7glWuu9lN+lWMJCk2GNwz0x5lWxulP35WqPZSAB7rlT4ZVqz+qv0XvLFMutu/sK+Ka8QAXgKZIsB+opwE+sidfVU+aPaTpoJC448PECY8Gks0E1XZDQ4fDpGL0jceeC/h1bCgedQypHf4ii6cLwcU1zpaGwRmA4weC0fkP7dxMaVxejHKj1UuKV7WtRTRd8MRjjjRPRLMjrOj+r886JCDN/6fYEVTXBR6eifHXx5o4ntCh469sIF6eS9gIVwNEfY/x0JX8rLSbh3ETSXmt06JLK6aBWUJ/dWxQan/TaB1TTBV2/Jgrq8+KjxdRWFdvL607MaMwuCyMlRRK771eo2KQgyfB2T+zfZ14Fmp/28mB5kf3Cy4WppSlbfbeL55/ycqsv7Q7mI0v53yafxKF6H2W3u+wZR6eupWF2lLl4qdaH4spOvh+6Q+Zgvc/Q2Gk4aCwp8CnwQrU3C7LEK7P/sWKeeMBNkcu8HZEhoJIEjVVubrsl21ouGXZtLcZsGTJvPIrE4xXWOkU1xKL763y4FWtt1A2xqNUg8waVMnmr1ZRQxepb9PKMZjnQy1e11QftHIwTntctAxme1+n8Of8TCqmhI5S3/SWg1q+weUN+v4/bBbu2elBukvjEVEH/hQSpPL9k+lqKUwVuGAryugLSAwTz7xNRBc9uX3lHoqegqz/GmZCxS8Pw/OuzsSRDl9QVn38/HDcc0hRQgCMDca7MZa/v8xMqXaOqfePof5US8N7JKAvRpZ3LZFjjSL95x52mnQLOxQVvHo/wTEURCU3wzXgSzcQTe1P/OZqLCz4xaarmmrprM7K5UmXS9a5O16hMuqjX6RqQgWPrAPRLeSE43ke6ctmpGlkIjp9ZN2WsMkCmBr3dgZDt1+vrl1dgtwLdDoLsRqI1KwUMNPt1IdHkEMu2C4mmwGs5Lg8sl+OvgyxX3etf49v8iK0u+ESnh/t6330u54v/ANPdaJCn+0gpAAAAAElFTkSuQmCC"

version = "1.0.4"
iconpath = {
    "Windows": "/temp/ForwardNotifierIcon",
    "Linux": "/tmp/ForwardNotifierIcon",
    "Darwin": "/tmp/ForwardNotifierIcon", #mac
    "MacOS": "/tmp/ForwardNotifierIcon"
}

tries = 0
def checkforupadate():
    global tries
    try:
        url = "https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py"
        r = requests.get(url).text
        m = re.search(r'version = .+', r)
        ver = m.group(0).split("=")[1].replace('"', "").replace(" ", "")
        if ver != version:
            sendnotif("Update availabe!",
                      "Run the install script again to update ForwardNotifier", platform.system(), "ForwardNotifier", forwardnotifiericon)
    except requests.exceptions.ConnectionError:
        if tries < 5:
            sendnotif("Couldn't access github", "Trying again in 5 seconds.", platform.system(), "ForwardNotifier", forwardnotifiericon)
            time.sleep(5)
            tries += 1
            checkforupadate()
        else:
            sendnotif("Couldn't access github", "Please check your internet connection or contact the developer.", platform.system(), "ForwardNotifier", forwardnotifiericon)


# send os with the request since it's known by the sender
def sendnotif(Title, Message, OS, appname=None, icon=None):
    # system = platform.system()
    try:
        try:  # Try to decode
            Title = base64.b64decode(Title.encode("utf-8")).decode("utf-8")
        except:
            print("Title is not base64")
        try:  # Try to decode
            Message = base64.b64decode(Message.encode("utf-8")).decode("utf-8")
        except:
            print("Message is not base64")
        if icon:
            print("Theres an icon!")
            icon = base64.decodebytes(icon.encode("utf-8"))
            if OS == "Linux":
                imageFile = "/tmp/"+appname
                open(imageFile, "wb").write(icon)
            else:
                open(iconpath[OS], "wb").write(icon) # send img to correct path

        print("Sending notification:")
        print("Title: ", Title)
        print("Message: ", Message)
        print("App Name: ", appname)

        if OS == "Windows":
            if icon:
                # try:  # Try to decode
                filename = iconpath[OS]
                img = Image.open(filename)
                img.save(iconpath[OS] + '.ico', format = 'ICO')
                toaster.show_toast(Title,
                                    Message,
                                    icon_path=iconpath[OS] + ".ico",
                                    duration=5,
                                    threaded=True)
                # except:  # icon not base64 aka ignore
                #     toaster.show_toast(Title,
                #                        Message,
                #                        duration=5,
                #                        threaded=True)
            else:
                toaster.show_toast(Title,
                                Message,
                                duration=5,
                                threaded=True)
        elif OS == "Linux":
            if icon:
                imageFile = "/tmp/"+appname
                subprocess.call(
                    ["notify-send", "-i", imageFile, Title, Message])
            else:
                subprocess.call(
                    ["notify-send", "-i", "applications-development", Title, Message])
        elif OS == "Darwin" or OS == "MacOS": # macos
            if icon:
                subprocess.call(["/usr/local/bin/terminal-notifier",
                                "-sound", "pop", "-appIcon", iconpath[OS], "-title", Title, "-message", Message])
            else:
                subprocess.call(["/usr/local/bin/terminal-notifier",
                    "-sound", "pop", "-title", Title, "-message", Message])
    except:
        sendnotif("Error", "unknown error while sending notification", platform.system())


def checkbody(body):  # checking the body for a post request, wont be a problem since we send it
    try:
        try:
            body = json.loads(body)
        except:
            return [False, "Unable to parse json"]

        if "Title" not in body:
            return [False, "No 'Title' in body"]

        if "Message" not in body:
            return [False, "No 'Message' in body"]

        if "OS" not in body:
            return [False, "No 'OS' in body"]

        if "img" in body:
            try:
                base64.decodebytes(body["img"].encode("utf-8"))
            except:
                return [False, "Img not base64"]


        return [True]
    except:
        return [False, "unknown error"]


class S(BaseHTTPRequestHandler):
    def send_res(self, args, code=200, Success=True):

        self.send_response(code)
        self.send_header('Content-type', 'text/html')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        out = {
            "Success": Success,
            "value": args
        }
        print("Sending: ", json.dumps(out).encode('utf-8'))
        self.wfile.write(json.dumps(out).encode('utf-8'))

    def do_GET(self):

        print("\nPath:", self.path)
        print(self.headers)

        self.send_res(
            "Send a Post with a title and a message in a json format")

    def do_POST(self):
        # <--- Gets the size of data
        content_length = int(self.headers['Content-Length'])
        # <--- Gets the data itself
        post_data = self.rfile.read(content_length)
        # print(json.loads(post_data.decode('utf-8')))
        print("\nPath:", str(self.path),
              "\nHeaders:\n" + str(self.headers))
        print(content_length)
        if content_length > 0:
            try:
                body = post_data.decode('utf-8')
                print("Body:\n" + post_data.decode('utf-8'), "\n")
            except UnicodeEncodeError as e:
                print("ForwardNotifierReciver Error:", e)
                sendnotif("ForwardNotifierReciver Error:",
                          "invalid characters", platform.system())
            if checkbody(body)[0] == True:  # all good

                body = json.loads(body)
                if "img" in  body:
                    if "appname" in body:
                        sendnotif(body["Title"], body["Message"],
                                  body["OS"], body["appname"], body["img"])  # sends the body
                    else:
                        sendnotif(body["Title"], body["Message"],
                                  body["OS"], body["img"])
                else:
                    sendnotif(body["Title"], body["Message"],
                              body["OS"])  # sends the body

                self.send_res("Sent!")

            else:  # Body is wrong

                print(checkbody(body)[1])  # send the error
                self.send_res(checkbody(body)[1], Success=False, code=400)

        else:
            self.send_res(
                "POST request for {} . Please send a body".format(self.path), Success=False)


def run(server_class=HTTPServer, handler_class=S, port=port):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd on port', port, '...')
    checkforupadate()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print('\nStopping httpd...')


if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
