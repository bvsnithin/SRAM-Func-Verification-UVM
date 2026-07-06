#!/usr/bin/env python3
import os
import sys
import subprocess
import argparse

# List of tests to run in the regression
TESTS = [
    "addr0_test",
    "addr1_test",
    "hsize_test",
    "low_power_test",
    "base_test",
    "all_sizes_test",
    "bank_boundary_test",
    "walking_data_test",
    "back_to_back_test",
    "all_byte_offsets_test",
    "reset_write_test",
    "stress_random_test"
]

def run_command(cmd, log_file=None):
    print(f"Running: {cmd}")
    try:
        # Run in shell to support environment setup from source commands
        if log_file:
            with open(log_file, "w") as f:
                result = subprocess.run(cmd, shell=True, stdout=f, stderr=subprocess.STDOUT, check=True)
        else:
            result = subprocess.run(cmd, shell=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}")
        print(f"Exit code: {e.returncode}")
        return False

def main():
    parser = argparse.ArgumentParser(description="SRAM Controller UVM Testbench Regression Suite")
    parser.add_argument("--clean", action="store_true", help="Clean simulation artifacts before running")
    parser.add_argument("--test", type=str, help="Run a single test instead of full regression")
    args = parser.parse_args()

    # Clean/Delete old run files when requested by user. Use makefile
    if args.clean:
        print("Cleaning up old simulation files...")
        run_command("make clean")

    # Compile the testbench snapshot once to ensure there are no syntax/structural errors
    print("\nCompiling design and testbench snapshot...")
    if not run_command("make compile"):
        print("Pre-compile failed. Aborting regression.")
        sys.exit(1)

    # Determine tests to run. If a specific test is passed, then run that test. Or else, all the tests are executed
    tests_to_run = [args.test] if args.test else TESTS
    results = {}

    print("::::::::::::::::::::::::::::::::::::::::::::::::::")
    print("Starting SRAM Controller Verification Regression")
    print("::::::::::::::::::::::::::::::::::::::::::::::::::")

    for test in tests_to_run:
        print(f"\n---> Running Test: {test}")
        log_file = f"{test}.log"
        # Run the test using Makefile
        cmd = f"make run TEST={test}"
        
        success = run_command(cmd)
        
        # Check simulation status from log or exit code
        if success:
            # Check for UVM errors/fatals in log
            has_errors = False
            if os.path.exists(log_file):
                with open(log_file, "r") as f:
                    content = f.read()
                    if "UVM_ERROR :" in content or "UVM_FATAL :" in content:
                        has_errors = True
            
            if has_errors:
                results[test] = "FAILED (UVM Error)"
            else:
                results[test] = "PASSED"
        else:
            results[test] = "FAILED (Compile/Simulation Crash)"

    print("\n::::::::::::::::::::::::::::::::::::::::::::::::::")
    print("Regression Results Summary")
    print("::::::::::::::::::::::::::::::::::::::::::::::::::")
    all_passed = True
    for test, status in results.items():
        print(f"{test:<20} : {status}")
        if "FAILED" in status:
            all_passed = False

    # Perform coverage merging if tests ran successfully
    if not args.test and os.path.exists("cov_work"):
        print("\n::::::::::::::::::::::::::::::::::::::::::::::::::")
        print("Merging Coverage Databases")
        print("::::::::::::::::::::::::::::::::::::::::::::::::::")
        # Call Makefile to merge coverage databases using Cadence IMC
        merge_success = run_command("make merge_cov")
        if merge_success:
            print("Coverage successfully merged to: merged_cov")
            print("To view coverage interactively, run: imc -load merged_cov")
        else:
            print("Failed to merge coverage databases.")

    print("::::::::::::::::::::::::::::::::::::::::::::::::::")
    if all_passed:
        print("ALL TESTS PASSED")
        sys.exit(0)
    else:
        print("SOME TESTS FAILED")
        sys.exit(1)

if __name__ == "__main__":
    main()
