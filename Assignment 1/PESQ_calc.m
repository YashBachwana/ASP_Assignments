function PESQ_calc()

    pesq_scores = pesq('Audio.wav', 'Processed.wav');

    fprintf('PESQ score of recorded:        %.3f\n', pesq_scores);
end
