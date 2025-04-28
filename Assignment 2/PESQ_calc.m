function PESQ_calc(P, fs, out)
    % Compute minimum common length
    min_len = min([length(out.desired), length(out.apa_output), length(out.nlms_output)]);

    % Step 1: Extract and convert
    d_ref = double(out.desired(1:min_len));
    apa_denoised = double(out.apa_output(1:min_len));
    nlms_denoised = double(out.nlms_output(1:min_len));

    % Step 2: Resample to 16 kHz
    target_fs = 16000;
    d_ref = resample(d_ref, target_fs, fs);
    apa_denoised = resample(apa_denoised, target_fs, fs);
    nlms_denoised = resample(nlms_denoised, target_fs, fs);

    % Step 3: Normalize after resampling
    d_ref = d_ref / max(abs(d_ref));
    apa_denoised = apa_denoised / max(abs(apa_denoised));
    nlms_denoised = nlms_denoised / max(abs(nlms_denoised));

    % Step 4: Save to WAV
    audiowrite('ref.wav', d_ref, target_fs);
    audiowrite('apa.wav', apa_denoised, target_fs);
    audiowrite('nlms.wav', nlms_denoised, target_fs);

    % Step 5: Compute PESQ
    pesq_apa = pesq('ref.wav', 'apa.wav');
    pesq_nlms = pesq('ref.wav', 'nlms.wav');

    % Step 6: Store PESQ APA in persistent dictionary
    persistent pesq_dict
    if isempty(pesq_dict)
        pesq_dict = struct();
    end
    pesq_dict.(sprintf('P_%d', P)) = pesq_apa;

    % Step 7: Display results
    fprintf('PESQ APA (P = %d): %.3f\n', P, pesq_apa);
    fprintf('PESQ NLMS:        %.3f\n', pesq_nlms);

    % Step 8: Display dictionary
    disp('PESQ APA values by reuse length (P):');
    disp(pesq_dict);
end
