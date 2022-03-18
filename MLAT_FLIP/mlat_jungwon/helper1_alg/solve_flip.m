% 2022/01/20
% Zahra Arjmandi


function set_xyz_stage1_flipped_out = solve_flip(set_xyz_stage1_out, set_pos_uwb)
Aap=set_pos_uwb;
Bap=-[1;1;1;1];
Pap=Aap\Bap;

if set_xyz_stage1_out(3)<0.2
    v=(Pap(1)*set_xyz_stage1_out(1)+Pap(2)*set_xyz_stage1_out(2)+Pap(3)*set_xyz_stage1_out(3)+1)/norm(Pap);
    set_xyz_stage1_flipped_out = set_xyz_stage1_out-2*Pap'/norm(Pap)*v;
else
    set_xyz_stage1_flipped_out = set_xyz_stage1_out;
end


