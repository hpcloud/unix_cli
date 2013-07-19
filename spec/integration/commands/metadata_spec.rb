require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "metadata" do
  context "metadata" do
    it "should report success" do
      tainer = ":objmeteatst"
      cptr("remove -f #{tainer}")
      cptr("containers:add #{tainer}")
      cptr("copy spec/fixtures/files/Matryoshka/Putin/Medvedev.txt #{tainer}")

      rsp = cptr("metadata #{tainer}/Medvedev.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Content-Type text/plain\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata #{tainer}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("X-Container-Bytes-Used 16\nX-Container-Object-Count 1\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata:set #{tainer}/Medvedev.txt X-Object-Meta-Foo valuu")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("The attribute 'X-Object-Meta-Foo' with value 'valuu' was set on object ':objmeteatst/Medvedev.txt'.\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata:set #{tainer} X-Container-Meta-Foo valtoo")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("The attribute 'X-Container-Meta-Foo' with value 'valtoo' was set on object ':objmeteatst'.\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata #{tainer}/Medvedev.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Content-Type text/plain\nX-Object-Meta-Foo valuu\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata #{tainer}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("X-Container-Bytes-Used 16\nX-Container-Meta-Foo valtoo\nX-Container-Object-Count 1\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
