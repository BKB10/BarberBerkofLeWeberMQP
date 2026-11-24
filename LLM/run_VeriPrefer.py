import torch
from pathlib import Path
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

#context directory
context_dir =  "lut_pack_context"

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


# Read all context files in a stable order.
context_dir = Path(__file__).resolve().parent / context_dir
context_files = sorted(path for path in context_dir.rglob("*") if path.is_file())
prompt = "\n\n".join(
    f"--- {path.relative_to(context_dir)} ---\n{path.read_text(encoding='utf-8')}"
    for path in context_files
)

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
    max_new_tokens=1024
)

# Trim the input prompt tokens from the output
generated_ids = [
    output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
]

response = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
print("Generated response, stored in model_output.txt:", response)
Path("./model_output.txt").write_text(response, encoding="utf-8")

