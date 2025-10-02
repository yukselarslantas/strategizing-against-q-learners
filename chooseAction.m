function action = chooseAction(probDist)
    r = rand();
    cumProb = cumsum(probDist);
    action = find(r<=cumProb,1,'first');
end
