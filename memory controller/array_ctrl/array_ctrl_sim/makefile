WORKSPACE = ..
LAB_DIR = ${WORKSPACE}/array_ctrl_rtl
VFILES = ${LAB_DIR}/*.v
TBFILE = ./tb_array_ctrl.v
FSDBFILE = wave_array_ctrl.fsdb

lint:
	vcs -full64 -debug_acc+all $(TBFILE) $(VFILES)
elab:
	vcs -R -full64 -debug_acc+all -fsdb $(TBFILE) $(VFILES)
run:
	./simv -l run.log
rung:
	./simv -gui -l run.log
verdi:
	verdi $(TBFILE) $(VFILES) -ssf $(FSDBFILE) &
all: clean elab run verdi
clean:
	rm -rf AN.DB \
	rm -rf DVEfiles \
	rm -rf csrc \
	rm -rf simv.* \
	rm -rf *simv \
	rm -rf inter.vpd \
	rm -rf ucli.key \
	rm -rf *.log \
	rm -rf verdiLog \
	rm -rf novas* \
	rm -rf *.fsdb
