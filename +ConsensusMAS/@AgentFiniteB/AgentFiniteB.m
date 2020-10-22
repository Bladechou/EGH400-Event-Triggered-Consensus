classdef AgentFiniteB < ConsensusMAS.Agent
    % This class represents a network agent
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        L;
        
        
        E;
        Y;
        Z;
    end
    
    methods
        function obj = AgentFiniteB(id, A, B, C, D, K, x0, delta, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, K, x0, delta, CLK);
            
            % Event triggering constant
            obj.k = 0;
        end
        
        function set.L(obj, L)
            obj.k = 1/max(eig(L));
        end
        
        function Z = get.Z(obj)
            Z = zeros(size(obj.x));
            for leader = obj.leaders
                xj = leader.agent;
                Z = Z - leader.weight*(...
                    (obj.xhat - xj.xhat) + ...
                    (obj.delta - xj.delta));
            end
        end
        
        function Y = get.Y(obj)
            Y = zeros(size(obj.x));
            for leader = obj.leaders
                xj = leader.agent;
                Y = Y - leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta));
            end
        end
        
        function E = get.E(obj)
            E = zeros(size(obj.x));
            for leader = obj.leaders
                xj = leader.agent;
                E = E - leader.weight*(...
                        (obj.error - xj.error));
            end
        end
        
        
         
        function setinput(obj)
            % Calculate the next control input
            z = zeros(size(obj.H, 1),1);
            for leader = obj.leaders     
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.xhat - xj.xhat) + ...
                    (obj.delta - xj.delta));
            end
                        
            beta = 0.2;
            gamma = 0.8;
            obj.u = -beta * sign(z) * abs(z)^gamma;
        end
        
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta));
            end
            
            % Consensus
            error_threshold = 0.5 * abs(z);
        end
     
        function triggers = triggers(obj)
            triggers = (abs(obj.E) <= 2 * abs(obj.Y));
            if any(triggers)
                triggers = ones(size(obj.x));
            end
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end