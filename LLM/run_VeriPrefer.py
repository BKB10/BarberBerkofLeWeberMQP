import torch
#from pathlib import Path
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

#model id from huggingface
model_id = "LLM-EDA/VeriPrefer-Qwen2.5-Coder-7B"

#Config
tokenizer = AutoTokenizer.from_pretrained(model_id)

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_quant_type="nf4"
)

model = AutoModelForCausalLM.from_pretrained(
    model_id,
    quantization_config=bnb_config,
    device_map="auto"
)


#Read prompt
with open('/home/dwbarber/MQP/BarberBerkofLeWeberMQP/model_scripts/context/chi_prompt.txt',"r", encoding="utf-8") as prompt_f:
    prompt = prompt_f.read()

messages = [
    {"role": "system", "content": "You are a helpful Verilog hardware design assistant."},
    {"role": "user", "content": prompt}
]

text = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True
)

model_inputs = tokenizer([text], return_tensors="pt").to(model.device)

#Generate the result
generated_ids = model.generate(
    **model_inputs,
    max_new_tokens=512
)

# Trim the input prompt tokens from the output
generated_ids = [
    output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
]

response = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
print(response)

