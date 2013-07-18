require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "objects:metadata:get" do
  context "objects:metadata:get" do
    it "should report success" do
      tainer = ":objmeteatst"
      cptr("containers:add #{tainer}")
      cptr("copy spec/fixtures/files/Matryoshka/Putin/Medvedev.txt #{tainer}")

      rsp = cptr("objects:metadata:get #{tainer}/Medvedev.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Content-Type text/plain\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("objects:metadata:set #{tainer}/Medvedev.txt X-Object-Meta-Foo valuu")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("The attribute 'X-Object-Meta-Foo' with value 'valuu' was set on object ':objmeteatst/Medvedev.txt'.\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("objects:metadata:get #{tainer}/Medvedev.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Content-Type text/plain\nX-Object-Meta-Foo valuu\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
