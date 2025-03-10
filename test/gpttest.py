# from openai import OpenAI

# client = OpenAI()

# OpenAI().api_key = 'sk-svcacct-1aN5BMPRBAQrImKK9rJUHh_dQiRKaMilbzHz84SkLhoA67opL5stnL9o10L41hT3BlbkFJhkSBpFJ40HRrz9nHiUhiEb5BR6pOxPx5MHt2tZHFJmJlwy3C9eRvIQRbppFskA'


# completion = client.chat.completions.create(
#     model="gpt-4o",
#     messages=[
#         {
#             "role": "user",
#             "content": [
#                 {"type": "text", "text": "Please analyze the following image of a performance assessment notice. Identify the subject, theme, maximum score, and assessment criteria from the image. print in korean"},
#                 {
#                     "type": "image_url",
#                     "image_url": {
#                         "url": "http://snowman0919.kro.kr:8080/api/files/uhgqhfa6j09vwzb/tgguzm2glpiizol/image_picker_6394_bee5_9_da3_439_b_a927_47_c640_ecc42_e_12103_00000_d8_d412198_ed_xfI3u4u2PY.jpg",
#                     }
#                 },
#             ],
#         }
#     ],
# )

# print(completion.choices[0].message)

import random

a = int(input('몇 명 출력? '))
list_1 = []

for i in range(a):
    while 1:
        num = random.randrange(1, 31)
        if num in list_1:
            num = random.randrange(1, 31)
            if num in list_1: continue
        if not num in list_1: break
    list_1.append(num)
    print(num,'번 당첨!')
print(list_1.sort())