# Core ML Models Guide for Astronaut Chat

This guide explains how to train and integrate Core ML models for each astronaut to make them sound authentic.

## Overview

The app is now set up to support per-astronaut Core ML models. Each astronaut can have their own trained model file that will be loaded when chatting with that astronaut.

## Current Implementation

- **Model Loading**: Models are loaded on-demand and cached
- **Fallback System**: If a model isn't available, the app uses enhanced mock responses with astronaut-specific characteristics
- **Model Files**: Expected in app bundle as `.mlmodelc` files:
  - `reid_wiseman.mlmodelc`
  - `victor_glover.mlmodelc`
  - `christina_koch.mlmodelc`
  - `jeremy_hansen.mlmodelc`

## Training Process

### Step 1: Collect Training Data

For each astronaut, gather publicly available text:
- NASA biography pages
- Interview transcripts
- Public speeches and presentations
- Social media posts (if public)
- Articles and Q&A sessions

**Sources:**
- NASA.gov astronaut pages
- YouTube interview transcripts
- News articles
- Podcast transcripts

**Format**: Plain text files, one document per astronaut (e.g., `reid_wiseman.txt`)

### Step 2: Prepare Training Data

Create training examples in a format suitable for fine-tuning:

```
System: [Persona prompt]
User: [Question]
Assistant: [Astronaut's actual response or similar style response]
```

### Step 3: Choose Base Model

For on-device inference with 25MB limit, consider:

**Option A: Small Quantized Models**
- Apple's Core ML optimized models
- Quantized Llama 2 7B (4-bit quantization)
- Phi-2 (Microsoft's small model)

**Option B: LoRA/Adapter Approach** (Recommended)
- One base model (~10-15MB)
- Small adapter files per astronaut (~1-2MB each)
- Total: ~18-23MB (fits within limit)

### Step 4: Fine-Tuning

#### Using Hugging Face + Core ML Tools

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
import coremltools as ct

# Load base model
model_name = "microsoft/phi-2"  # or another small model
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name)

# Fine-tune on astronaut data
# (Use your preferred fine-tuning method: LoRA, full fine-tuning, etc.)

# Convert to Core ML
mlmodel = ct.convert(
    model,
    inputs=[ct.TensorType(name="input_ids", shape=(1, 512))],
    outputs=[ct.TensorType(name="logits")],
    compute_units=ct.ComputeUnit.ALL
)

# Save
mlmodel.save("reid_wiseman.mlmodelc")
```

#### Using Apple's MLX (Recommended for Apple Silicon)

```python
import mlx.core as mx
import mlx.nn as nn
from mlx_lm import load, generate

# Load and fine-tune
model, tokenizer = load("mlx-community/phi-2-2.7b")

# Fine-tune on astronaut-specific data
# (Implement fine-tuning loop)

# Convert to Core ML format
# (Use coremltools or Apple's conversion tools)
```

### Step 5: Optimize for Size

1. **Quantization**: Use 4-bit or 8-bit quantization
2. **Pruning**: Remove less important weights
3. **Knowledge Distillation**: Train smaller student model
4. **Compression**: Use Core ML's built-in compression

### Step 6: Add Models to Xcode Project

1. Drag `.mlmodelc` files into Xcode project
2. Ensure they're added to app target
3. Verify they're included in bundle
4. Check file sizes (aim for <5MB each)

## Model Architecture Considerations

### Input Format
- Tokenized text (token IDs)
- Max sequence length: 512-1024 tokens
- Include system prompt + conversation history

### Output Format
- Token logits or probabilities
- Decode tokens back to text
- Apply temperature/sampling for variety

### Inference Pipeline

```swift
// Pseudocode for runInference implementation
1. Tokenize prompt using tokenizer
2. Convert tokens to MLMultiArray
3. Run model.prediction(from: input)
4. Extract logits from output
5. Sample next token (with temperature)
6. Decode token to text
7. Repeat until end token or max length
8. Return generated text
```

## Testing

1. **Without Models**: App should use fallback responses (current behavior)
2. **With Models**: Responses should reflect astronaut's speaking style
3. **Performance**: Inference should complete in <2 seconds on device
4. **Memory**: Models should load without excessive memory usage

## Size Optimization Tips

1. **Use LoRA**: Instead of full fine-tuning, use Low-Rank Adaptation
2. **Share Base Model**: One base model, multiple small adapters
3. **Quantize Aggressively**: 4-bit quantization can reduce size by 75%
4. **Limit Vocabulary**: Use smaller tokenizer if possible
5. **Prune Models**: Remove redundant weights

## Example Training Script Structure

```python
# train_astronaut_model.py
import torch
from transformers import AutoModelForCausalLM, TrainingArguments, Trainer

def prepare_dataset(astronaut_name):
    # Load astronaut's text corpus
    # Format as training examples
    # Return dataset
    pass

def fine_tune_model(base_model, astronaut_data):
    # Set up training arguments
    # Create trainer
    # Fine-tune
    # Save model
    pass

# Train each astronaut
for astronaut in ["reid_wiseman", "victor_glover", "christina_koch", "jeremy_hansen"]:
    data = prepare_dataset(astronaut)
    model = fine_tune_model(base_model, data)
    convert_to_coreml(model, f"{astronaut}.mlmodelc")
```

## Legal & Ethical Considerations

- ✅ Only use publicly available information
- ✅ Clearly label as simulated personas
- ✅ Don't claim to be the real person
- ✅ Respect privacy boundaries
- ✅ Use for educational purposes only

## Next Steps

1. Collect training data for each astronaut
2. Choose and prepare base model
3. Fine-tune models (or use LoRA adapters)
4. Convert to Core ML format
5. Optimize for size
6. Add to Xcode project
7. Test inference performance
8. Update `runInference` method in `LLMManager.swift` with actual implementation

## Resources

- [Core ML Tools Documentation](https://coremltools.readme.io/)
- [Apple MLX Framework](https://github.com/ml-explore/mlx)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [Core ML Model Format](https://developer.apple.com/documentation/coreml)

## Current Status

✅ Infrastructure ready for model loading
✅ Per-astronaut model support implemented
✅ Fallback system working
⏳ Models need to be trained and added
⏳ Inference implementation needs Core ML model details

Once models are trained and added, update the `runInference` method in `LLMManager.swift` to implement actual tokenization, prediction, and decoding.

