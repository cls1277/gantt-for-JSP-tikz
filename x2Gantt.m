function x2Gantt(x,bkg,sp)
    sp = 'E:\cls1277\GitHub\DGFJSP\notes\test3.txt';
    bkgmachine = bkg.machine;
    [a, b, c] = evaluate(x, bkg);
    c = c(3);
    mx = max(b);
    colors = {'yellow!50', 'blue!50', 'orange!50', 'gray!50', 'pink!50', 'red!50', 'green!50', 'purple!50', 'cyan!50', 'white!50', 'yellow', 'blue', 'orange', 'gray', 'pink', 'red', 'green', 'purple', 'cyan', 'white', };
    c1 = '\begin{tikzpicture}[';
    c11_ = 'dot/.style={circle,minimum size=8pt}]';
    c2 = '\coordinate (';
    c3 = ') at (';
    c4 = ',';
    c5 = ');';
    c6 = '\draw[-latex][very thick] (-0.5,0) -- (';
    c7 = ',0) node[below] {\small $F1$};';
	c8 = '\draw[-latex][very thick] (0,-0) -- (0,';
    c9 = ') node[above] {\small $Machine$};';
    c10 = '\end{tikzpicture}';
    c11 = '\draw (';
    c111 = ') node [below]{';
    c12 = '} -- ++(0, 3pt) ;';
    c111_ = ') node [left]{$M_';
    c12_ = '$} -- ++(0, 3pt) ;';
    d1 = '\filldraw[fill = ';
    d2 = '][thick] (';
    d3 = ') rectangle (';
    d4 = ') node[left, black, xshift=';
    d5 = 'pt, yshift = ';
    d6 = 'pt] {\small $O_{';
    d7 = '}$};';
%     dx = [0,0,0,0,-];
    fid = fopen(sp,'w');
    fprintf(fid, "%s\r\n\t%s\r\n", c1, c11_);
    for i = 0:mx
        fprintf(fid, "\t%sa%d%s%d%s0%s\r\n",c2,i,c3,i,c4,c5);
    end
    for i = 0:bkgmachine-1
        fprintf(fid, "\t%sb%d%s0%s%f%s\r\n",c2,i+1,c3,c4,i+0.5,c5);
    end
    fprintf(fid, "\t%s%d%s\r\n\t%s%d%s\r\n",c6,mx+1,c7,c8,bkgmachine+1,c9);
    for i = 0:mx
        fprintf(fid, "\t%sa%d%s%d%s\r\n",c11,i,c111,i,c12);
    end
    for i = 0:bkgmachine-1
        fprintf(fid, "\t%sb%d%s%d%s\r\n",c11,i+1,c111_,i+1,c12_);
    end
    cnt_j = zeros(bkg.job, 1);
%     ddd = [];
    for i = bkg.job+bkg.operation+1:bkg.job+bkg.operation*2
        job = x(i);
        factory = x(job);
        if factory~=c
            continue
        end
        cnt_j(job) = cnt_j(job) + 1;
        machine = getMachine(job, cnt_j(job));
%         ddd = [ddd; b(i-bkg.job-bkg.operation,1)-a(i-bkg.job-bkg.operation,1)];
        ttt = b(i-bkg.job-bkg.operation,1)-a(i-bkg.job-bkg.operation,1);
        fprintf(fid, "\t%s%s%s%d,%d%s%d,%f%s%d%s%d%s%d,%d%s\r\n",d1,colors{1,job},d2,a(i-bkg.job-bkg.operation,1),machine-1,d3,b(i-bkg.job-bkg.operation,1),machine-0.25,d4,-(1+13*(ttt-1)),d5,-12,d6,job,cnt_j(job),d7);
    end
%     ddd = unique(ddd, 'rows');
    fprintf(fid, "%s\r\n",c10);
    fclose(fid);
    
    function m = getMachine(j, c)
        pre = bkg.job + sum(bkg.operations(1:j-1)) + c;
        m = x(pre);
    end
end

function [st, et, p] = evaluate(x, bkg)
    st = zeros(bkg.operation, 1);
    et = zeros(bkg.operation, 1);
    % 常数：Ep加工功率(4) Es等待功率(1)
    E = [4; 1];
    if size(x,2)==1
        x = x';
    end
    % x是行向量
    p = zeros(3, 1);
    time_m = zeros(bkg.factory, bkg.machine);
    time_j = zeros(bkg.job, 1);
    cnt_j = zeros(bkg.job, 1);
    time_E = zeros(1, 2);
    for i = bkg.job+bkg.operation+1:bkg.job+bkg.operation*2
        job = x(i);
        factory = x(job);
        cnt_j(job) = cnt_j(job) + 1;
        machine = getMachine(job, cnt_j(job));
        machines = cell2mat(bkg.machines{job}(cnt_j(job)));
        times = cell2mat(bkg.times{job}(cnt_j(job)));
        time = times(machines==machine);
        t = max(time_m(factory, machine), time_j(job));
        st(i-bkg.job-bkg.operation,1) = t;
        time_E(1) = time_E(1) + time;
        time_E(2) = time_E(2) + t - time_m(factory, machine);
        time_m(factory, machine) = t+time;
        time_j(job) = t+time;
        et(i-bkg.job-bkg.operation,1) = t+time;
    end
    [p(1), idx] = max(time_m(:));
    p(2) = time_E*E;
    p(3) = mod(idx, bkg.factory);
    if p(3)==0
        p(3) = bkg.factory;
    end
    
    function m = getMachine(j, c)
        pre = bkg.job + sum(bkg.operations(1:j-1)) + c;
        m = x(pre);
    end
end